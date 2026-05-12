import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://forgedesk_user:forgedesk_pass@localhost:5432/forgedesk_db"
)

FLASK_PORT = int(os.getenv("FLASK_PORT", 8000))
DEBUG = os.getenv("DEBUG", "False").lower() == "true"