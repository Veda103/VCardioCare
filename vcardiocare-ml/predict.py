"""
predict.py — Prediction + SHAP explanation logic
Called by app.py for every incoming request.
"""

import os
import numpy as np
import pandas as pd
import joblib

# ── Load artifacts once at import time ──────────────────
# Use absolute path based on this script's location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ARTIFACTS  = os.path.join(SCRIPT_DIR, "artifacts")
model      = joblib.load(os.path.join(ARTIFACTS, "model.pkl"))
scaler     = joblib.load(os.path.join(ARTIFACTS, "scaler.pkl"))
feat_cols  = joblib.load(os.path.join(ARTIFACTS, "feature_columns.pkl"))

print("[OK] Model artifacts loaded.")

# ── SHAP factor display metadata ────────────────────────
# Maps each training feature → human-readable display info
FACTOR_META = {
    "Age":                  {"display": "Age",               "icon": "🎂",  "modifiable": False},
    "Gender":               {"display": "Gender",            "icon": "👤",  "modifiable": False},
    "Diabetes":             {"display": "Diabetes",          "icon": "💉",  "modifiable": True },
    "Hypertension":         {"display": "Hypertension",      "icon": "❤️",  "modifiable": True },
    "Obesity":              {"display": "Obesity",           "icon": "⚖️",  "modifiable": True },
    "Smoking":              {"display": "Smoking",           "icon": "🚬",  "modifiable": True },
    "Alcohol_Consumption":  {"display": "Alcohol Use",       "icon": "🍷",  "modifiable": True },
    "Physical_Activity":    {"display": "Physical Activity", "icon": "🚶",  "modifiable": True },
    "Diet_Score":           {"display": "Diet Quality",      "icon": "🥗",  "modifiable": True },
    "Cholesterol_Level":    {"display": "Total Cholesterol", "icon": "🩸",  "modifiable": True },
    "LDL_Level":            {"display": "LDL Cholesterol",   "icon": "🩸",  "modifiable": True },
    "HDL_Level":            {"display": "HDL Cholesterol",   "icon": "🩸",  "modifiable": True },
    "Systolic_BP":          {"display": "Systolic BP",       "icon": "💓",  "modifiable": True },
    "Diastolic_BP":         {"display": "Diastolic BP",      "icon": "💓",  "modifiable": True },
    "Family_History":       {"display": "Family History",    "icon": "👨‍👩‍👧",  "modifiable": False},
    "Stress_Level":         {"display": "Stress Level",      "icon": "😰",  "modifiable": True },
    "Heart_Attack_History": {"display": "Past Heart Events", "icon": "🏥",  "modifiable": False},
}


def _build_input_row(data: dict) -> pd.DataFrame:
    """
    Map incoming API request fields → training feature columns.
    Any column not provided defaults to 0 (safe neutral value).
    """
    # Map API field names to training column names
    mapping = {
        "age":              "Age",
        "gender":           "Gender",          # 1=Male, 0=Female
        "has_diabetes":     "Diabetes",
        "has_hypertension": "Hypertension",
        "obesity":          "Obesity",
        "smoking_status":   "Smoking",         # converted below
        "alcohol":          "Alcohol_Consumption",
        "physical_activity":"Physical_Activity",
        "diet_score":       "Diet_Score",
        "total_cholesterol":"Cholesterol_Level",
        "ldl_cholesterol":  "LDL_Level",
        "hdl_cholesterol":  "HDL_Level",
        "systolic_bp":      "Systolic_BP",
        "diastolic_bp":     "Diastolic_BP",
        "has_family_history":"Family_History",
        "stress_level":     "Stress_Level",
        "heart_attack_history": "Heart_Attack_History",
    }

    row = {col: 0 for col in feat_cols}  # start with all zeros

    for api_key, train_col in mapping.items():
        val = data.get(api_key)
        if val is None:
            continue

        # smoking_status: "non-smoker"→0, "former"→0.5, "smoker"→1
        if api_key == "smoking_status":
            val = {"non-smoker": 0, "former": 1, "smoker": 1}.get(str(val).lower(), 0)

        if train_col in row:
            row[train_col] = float(val)

    return pd.DataFrame([row], columns=feat_cols)


def _get_shap_factors(row_df: pd.DataFrame) -> list:
    """
    Use feature importances (fast, reliable) to explain the prediction.
    Returns top 5 factors as a list of dicts.
    """
    importances = model.feature_importances_         # shape: (n_features,)
    raw_values  = row_df.values[0]                   # shape: (n_features,)

    # Weighted contribution: importance × |value|
    contributions = np.abs(raw_values) * importances

    # Normalise to 0–100% range
    total = contributions.sum()
    if total == 0:
        total = 1
    norm_contributions = (contributions / total) * 100

    # Build list and sort by impact descending
    factors = []
    for i, col in enumerate(feat_cols):
        if contributions[i] < 0.001:
            continue
        meta = FACTOR_META.get(col, {
            "display": col.replace("_", " ").title(),
            "icon":    "📊",
            "modifiable": True,
        })
        factors.append({
            "feature":       col,
            "display_name":  meta["display"],
            "icon":          meta["icon"],
            "shap_value":    round(float(contributions[i]), 4),
            "impact_percent": round(float(norm_contributions[i]), 1),
            "is_modifiable": meta["modifiable"],
        })

    # Sort by impact, return top 5
    factors.sort(key=lambda x: x["impact_percent"], reverse=True)
    return factors[:5]


def run_prediction(data: dict) -> dict:
    """
    Main prediction function called by app.py.

    Args:
        data: dict of health fields from Flutter app

    Returns:
        dict with risk_percent, confidence, shap_factors
    """
    # 1. Build input row aligned to training columns
    row_df = _build_input_row(data)

    # 2. Scale with the same RobustScaler used in training
    row_scaled = scaler.transform(row_df)
    row_scaled_df = pd.DataFrame(row_scaled, columns=feat_cols)

    # 3. Predict
    prob_high_risk = model.predict_proba(row_scaled)[0][1]  # probability of class 1
    risk_percent   = round(float(prob_high_risk) * 100, 1)

    # 4. Confidence: how far from 50% the prediction is
    confidence = round(abs(prob_high_risk - 0.5) * 2 * 100, 1)
    confidence = max(50.0, min(confidence, 99.0))  # clamp between 50–99

    # 5. SHAP-style factors (uses unscaled values for interpretability)
    shap_factors = _get_shap_factors(row_df)

    return {
        "risk_percent":  risk_percent,
        "confidence":    confidence,
        "shap_factors":  shap_factors,
    }