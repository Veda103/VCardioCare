"""
app.py — VCardioCare ML API Server (FastAPI)

Start with:
    uvicorn app:app --host 0.0.0.0 --port 8000 --reload

Then test at:
    http://localhost:8000/docs   (Swagger UI — auto-generated)
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
from predict import run_prediction

app = FastAPI(
    title="VCardioCare ML API",
    description="Heart attack risk prediction using Random Forest",
    version="1.0.0",
)


# ── Request schema ────────────────────────────────────────
# These are the fields the Flutter app sends via Node.js
class PredictRequest(BaseModel):
    # Vitals (required)
    systolic_bp:       float = Field(..., ge=70,  le=200, description="Systolic blood pressure")
    diastolic_bp:      float = Field(..., ge=40,  le=130, description="Diastolic blood pressure")
    age:               int   = Field(..., ge=1,   le=120, description="Age in years")

    # Blood work (required)
    total_cholesterol: float = Field(..., ge=50,  le=500, description="Total cholesterol mg/dL")

    # Optional fields (app may not collect all of these yet)
    bmi:               Optional[float] = Field(None, ge=10,  le=60)
    fasting_glucose:   Optional[float] = Field(None, ge=50,  le=500)
    ldl_cholesterol:   Optional[float] = Field(None, ge=0,   le=400)
    hdl_cholesterol:   Optional[float] = Field(None, ge=0,   le=200)

    # Lifestyle
    smoking_status:    Optional[str]   = "non-smoker"  # "non-smoker" | "former" | "smoker"
    sleep_hours:       Optional[float] = None
    stress_level:      Optional[float] = None          # 0–10
    physical_activity: Optional[float] = None          # 0=sedentary, 1=light, 2=moderate, 3=active
    diet_score:        Optional[float] = None          # 0–10
    alcohol:           Optional[int]   = 0             # 0=No, 1=Yes

    # Medical history
    has_diabetes:       Optional[int] = 0              # 0 or 1
    has_family_history: Optional[int] = 0
    has_hypertension:   Optional[int] = 0
    heart_attack_history: Optional[int] = 0
    obesity:            Optional[int] = 0

    # Demographics
    gender:             Optional[int] = 1              # 1=Male, 0=Female


# ── Response schema ───────────────────────────────────────
class ShapFactor(BaseModel):
    feature:        str
    display_name:   str
    icon:           str
    shap_value:     float
    impact_percent: float
    is_modifiable:  bool

class PredictResponse(BaseModel):
    risk_percent:  float
    confidence:    float
    shap_factors:  list[ShapFactor]


# ── Routes ────────────────────────────────────────────────

@app.get("/")
def root():
    return {"status": "VCardioCare ML API is running [OK]", "version": "1.0.0"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(request: PredictRequest):
    """
    Main prediction endpoint.
    Called by Node.js backend's prediction route.
    Returns risk_percent (0–100), confidence, and top 5 SHAP factors.
    """
    try:
        data = request.model_dump()
        result = run_prediction(data)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")