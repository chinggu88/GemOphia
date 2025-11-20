import os
from dotenv import load_dotenv

load_dotenv()

REQUIRED_KEYS = [
    "SUPABASE_URL",
    "SUPABASE_SERVICE_ROLE_KEY",
    "GEMINI_API_KEY"
]

missing = []
for key in REQUIRED_KEYS:
    if not os.getenv(key):
        missing.append(key)

if missing:
    print(f"❌ Missing environment variables: {', '.join(missing)}")
    exit(1)
else:
    print("✅ All required environment variables are set.")
