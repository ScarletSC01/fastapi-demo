from fastapi import FastAPI
from app.routes import health

app = FastAPI(title="DevOps Trivia API")

# Rutas
app.include_router(health.router)
