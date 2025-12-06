from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class PredictRequest(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(req: PredictRequest):
    # ここに実際のモデル呼び出しをつなぐ（現状はプレースホルダ）
    return {"input": req.text, "output": f"echo: {req.text}"}
