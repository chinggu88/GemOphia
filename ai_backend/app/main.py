"""
GemOphia AI Backend
FastAPI Main Application
"""
from contextlib import asynccontextmanager
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import get_settings
from .api.v1 import analysis
from .listeners.file_upload_listener import get_file_upload_listener

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Settings
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI 앱 생명주기 관리

    시작 시: Realtime Listener 시작
    종료 시: Realtime Listener 중지
    """
    # Startup
    logger.info("🚀 Starting GemOphia AI Backend...")

    file_listener = None
    try:
        # File Upload Realtime Listener 시작 (async)
        file_listener = get_file_upload_listener()
        await file_listener.start()  # await 추가
        logger.info("✅ File Upload Realtime Listener started successfully")
    except Exception as e:
        logger.error(f"❌ Failed to start File Upload Realtime Listener: {e}")
        # 리스너 실패해도 API는 계속 실행

    yield

    # Shutdown
    logger.info("🛑 Shutting down GemOphia AI Backend...")

    if file_listener:
        try:
            file_listener.stop()
            logger.info("✅ File Upload Realtime Listener stopped")
        except Exception as e:
            logger.error(f"Error stopping File Upload Realtime Listener: {e}")


# Create FastAPI app
app = FastAPI(
    title="GemOphia AI Backend",
    description="AI-powered couple relationship analysis API",
    version="0.1.0",
    debug=settings.debug,
    lifespan=lifespan  # 생명주기 관리 추가
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(analysis.router, prefix="/api/v1")


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "GemOphia AI Backend",
        "version": "0.1.0",
        "status": "running",
        "ai_provider": settings.ai_provider
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )
