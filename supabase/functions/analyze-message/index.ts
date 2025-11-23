/*
=== analyze-message Edge Function ===

이 함수가 하는 일:
Flutter 앱에서 메시지를 받아서 감정을 분석하고 결과를 반환한다.
Python FastAPI의 /api/v1/analysis/message 엔드포인트를 대체하는 서버리스 함수다.

처리 흐름:
1. HTTP POST 요청 받기 (Flutter에서 전송)
2. 요청 본문에서 메시지 내용 추출
3. Gemini API로 감정 분석 요청
4. 분석 결과를 JSON으로 반환

Python 버전과의 차이점:
- FastAPI 서버 필요 없음 (서버리스)
- Deno 런타임에서 실행 (Node.js 아님)
- npm 패키지는 "npm:" prefix로 import
*/

// Supabase Edge Runtime 타입 정의 (자동완성을 위한 설정)
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

// Google Generative AI SDK (Gemini API 사용을 위한 라이브러리)
// npm 패키지를 Deno에서 사용하려면 "npm:" prefix 필요
import { GoogleGenerativeAI } from "npm:@google/generative-ai@0.21.0"

/*
=== 타입 정의 ===
TypeScript는 타입을 명시하면 에디터가 자동완성을 해주고 오류를 미리 잡아준다.
Python의 type hints와 비슷한 개념이다.
*/

// 요청 본문 타입 (Flutter에서 보내는 데이터 구조)
interface AnalyzeRequest {
  couple_id: string    // 커플 ID
  sender_id: string    // 보낸 사람 ID
  content: string      // 분석할 메시지 내용
}

// 감정 점수 타입 (Python의 EmotionScore와 동일)
interface EmotionScore {
  emotion: string           // 주요 감정 ("기쁨", "슬픔" 등)
  confidence: number        // 확신도 (0~1)
  all_scores: {            // 7가지 감정 모두의 점수
    [key: string]: number  // key는 감정 이름, value는 점수
  }
}

// 응답 타입 (Flutter로 반환할 데이터 구조)
interface AnalyzeResponse {
  emotion: EmotionScore
  topics: string[]         // 주제 추출 (TODO: 나중에 구현)
  processed_at: string     // 처리 시간 (ISO 8601 형식)
}

/*
=== analyzeEmotion 함수 ===
Gemini API를 호출해서 텍스트의 감정을 분석한다.
Python의 GeminiEmotionAnalyzer.analyze_emotion()과 동일한 기능이다.

async 키워드:
- 이 함수는 비동기 함수다 (API 호출이 시간이 걸리기 때문)
- Python의 async def와 같은 개념
- await를 사용해서 API 응답을 기다린다
*/
async function analyzeEmotion(text: string): Promise<EmotionScore> {
  /*
  환경 변수에서 API 키 가져오기:
  - Python: os.getenv("GEMINI_API_KEY")
  - TypeScript: Deno.env.get("GEMINI_API_KEY")

  느낌표(!)는 "이 값이 null이 아니라고 확신한다"는 뜻
  없으면 TypeScript 컴파일러가 경고를 낸다
  */
  const apiKey = Deno.env.get("GEMINI_API_KEY")!

  // GoogleGenerativeAI 인스턴스 생성 (API 키로 인증)
  const genAI = new GoogleGenerativeAI(apiKey)

  /*
  모델 선택:
  - gemini-1.5-flash: 가장 빠르고 저렴한 모델
  - Python 버전과 동일한 모델 사용
  */
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" })

  /*
  프롬프트 작성:
  - 백틱(`)으로 감싸면 여러 줄 문자열 가능
  - ${변수} 형태로 변수 삽입 (Python의 f-string과 동일)
  - Python 버전의 프롬프트를 그대로 옮김
  */
  const prompt = `다음 한국어 텍스트의 감정을 분석해주세요.

텍스트: "${text}"

다음 7가지 감정에 대해 0~1 사이의 점수를 매겨주세요:
- 기쁨: 행복, 즐거움, 기쁨
- 슬픔: 슬픔, 우울, 외로움
- 화남: 화, 짜증, 분노
- 불안: 걱정, 불안, 긴장
- 중립: 평범함, 사실 전달
- 사랑: 애정, 사랑, 호감
- 피곤: 피곤함, 지침, 무기력

반드시 아래 JSON 형식으로만 응답해주세요 (다른 텍스트 없이):
{
  "기쁨": 0.0,
  "슬픔": 0.0,
  "화남": 0.0,
  "불안": 0.0,
  "중립": 0.0,
  "사랑": 0.0,
  "피곤": 0.0
}`

  /*
  Gemini API 호출:
  - generateContent(): 텍스트 생성 API
  - await: 응답이 올 때까지 기다린다 (비동기 처리)
  - generationConfig: 생성 설정 (temperature 등)
  */
  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.3,  // 낮을수록 일관된 결과 (0~1)
    },
  })

  /*
  응답 파싱:
  1. 텍스트 추출
  2. 마크다운 코드 블록 제거 (```json ... ```)
  3. JSON 파싱
  */
  const response = await result.response
  let responseText = response.text().trim()

  // 마크다운 코드 블록 제거
  // Gemini가 가끔 ```json ... ``` 형태로 응답하기 때문
  if (responseText.startsWith("```json")) {
    responseText = responseText.replace("```json", "").replace("```", "").trim()
  } else if (responseText.startsWith("```")) {
    responseText = responseText.replace(/```/g, "").trim()
  }

  /*
  JSON 파싱:
  - Python: json.loads(text)
  - TypeScript: JSON.parse(text)

  as 키워드: 타입 단언 (이 객체가 이런 타입이라고 확신)
  */
  const scores = JSON.parse(responseText) as { [key: string]: number }

  /*
  가장 높은 점수의 감정 찾기:
  - Object.entries(): 객체를 [key, value] 배열로 변환
  - reduce(): 배열을 순회하며 최댓값 찾기

  Python 버전:
  dominant_emotion = max(scores.items(), key=lambda x: x[1])

  TypeScript 버전:
  reduce로 최댓값을 가진 항목을 찾는다
  */
  const dominantEmotion = Object.entries(scores).reduce((max, current) => {
    return current[1] > max[1] ? current : max
  })

  /*
  결과 반환:
  - emotion: 주요 감정 이름
  - confidence: 주요 감정의 점수
  - all_scores: 7가지 감정 모두의 점수
  */
  return {
    emotion: dominantEmotion[0],
    confidence: dominantEmotion[1],
    all_scores: scores,
  }
}

/*
=== 메인 서버 함수 ===
Deno.serve()는 HTTP 서버를 실행한다.
Python의 FastAPI @app.post() 데코레이터와 비슷한 역할이다.

처리 흐름:
1. HTTP 요청 받기
2. JSON 본문 파싱
3. 감정 분석 실행
4. 결과를 JSON으로 반환
*/
Deno.serve(async (req) => {
  /*
  CORS 설정:
  - Flutter 앱에서 브라우저를 통해 호출할 때 필요
  - OPTIONS 요청(preflight)을 먼저 처리해야 함
  */
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    })
  }

  /*
  에러 처리:
  try-catch로 감싸서 에러가 나도 서버가 죽지 않게 한다
  Python의 try-except와 동일
  */
  try {
    /*
    요청 본문 파싱:
    - req.json(): JSON 본문을 객체로 변환
    - await: 비동기 처리 (읽기 완료될 때까지 기다림)
    - as AnalyzeRequest: 타입 단언

    Python 버전:
    data = await request.json()
    content = data["content"]
    */
    const requestBody = await req.json() as AnalyzeRequest
    const { content } = requestBody  // 구조 분해 할당 (content 필드만 추출)

    /*
    입력 검증:
    content가 없거나 빈 문자열이면 400 에러 반환
    */
    if (!content || content.trim() === "") {
      return new Response(
        JSON.stringify({ error: "content is required" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" }
        }
      )
    }

    /*
    감정 분석 실행:
    await로 분석이 완료될 때까지 기다린다
    */
    const emotion = await analyzeEmotion(content)

    /*
    응답 데이터 구성:
    - emotion: 분석 결과
    - topics: 빈 배열 (TODO: 나중에 주제 추출 기능 추가)
    - processed_at: 현재 시간 (ISO 8601 형식)

    Python 버전:
    return MessageAnalysisResponse(
        emotion=emotion,
        topics=[],
        processed_at=datetime.now()
    )
    */
    const responseData: AnalyzeResponse = {
      emotion: emotion,
      topics: [],  // TODO: 주제 추출 기능 추가
      processed_at: new Date().toISOString(),
    }

    /*
    HTTP 응답 반환:
    - JSON.stringify(): 객체를 JSON 문자열로 변환
    - headers: Content-Type과 CORS 설정
    - Python의 return JSONResponse()와 동일
    */
    return new Response(
      JSON.stringify(responseData),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",  // CORS: 모든 출처 허용
        },
      }
    )

  } catch (error) {
    /*
    에러 처리:
    분석 중 에러가 발생하면 500 에러 반환
    에러 메시지도 함께 전송 (디버깅용)
    */
    console.error("Analysis error:", error)

    return new Response(
      JSON.stringify({
        error: "Analysis failed",
        details: error.message
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    )
  }
})

/*
=== 로컬 테스트 방법 ===

1. 터미널에서 실행:
supabase functions serve analyze-message

2. 다른 터미널에서 테스트:
curl -i --location --request POST 'http://localhost:54321/functions/v1/analyze-message' \
  --header 'Content-Type: application/json' \
  --data '{
    "couple_id": "test-couple-123",
    "sender_id": "user-456",
    "content": "오늘 정말 행복해!"
  }'

3. 예상 응답:
{
  "emotion": {
    "emotion": "기쁨",
    "confidence": 0.89,
    "all_scores": {
      "기쁨": 0.89,
      "슬픔": 0.02,
      "화남": 0.01,
      "불안": 0.02,
      "중립": 0.03,
      "사랑": 0.02,
      "피곤": 0.01
    }
  },
  "topics": [],
  "processed_at": "2025-01-16T10:30:00.000Z"
}

=== 환경 변수 설정 ===

.env 파일 또는 supabase secrets:
GEMINI_API_KEY=your-api-key-here

로컬 테스트:
supabase functions serve analyze-message --env-file .env

배포 후 secrets 설정:
supabase secrets set GEMINI_API_KEY=your-api-key-here
*/
