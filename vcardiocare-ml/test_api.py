"""
test_api.py — Quick test to verify the API is working.
Run AFTER starting app.py with uvicorn.

Usage:
    python test_api.py
"""

import requests
import json

BASE_URL = "http://localhost:8000"

# ── Test 1: Health check ──────────────────────────────────
print("Test 1: Health check")
r = requests.get(f"{BASE_URL}/health")
print(f"  Status: {r.status_code}")
print(f"  Response: {r.json()}\n")

# ── Test 2: High-risk patient ────────────────────────────
print("Test 2: High-risk patient")
high_risk = {
    "age":               62,
    "gender":            1,
    "systolic_bp":       165,
    "diastolic_bp":      105,
    "total_cholesterol": 280,
    "ldl_cholesterol":   190,
    "hdl_cholesterol":   30,
    "smoking_status":    "smoker",
    "stress_level":      8,
    "physical_activity": 0,
    "has_diabetes":      1,
    "has_family_history":1,
    "has_hypertension":  1,
    "obesity":           1,
}
r = requests.post(f"{BASE_URL}/predict", json=high_risk)
result = r.json()
print(f"  Risk: {result['risk_percent']}%")
print(f"  Confidence: {result['confidence']}%")
print(f"  Top factor: {result['shap_factors'][0]['display_name']} — {result['shap_factors'][0]['impact_percent']}%")
print()

# ── Test 3: Low-risk patient ─────────────────────────────
print("Test 3: Low-risk patient")
low_risk = {
    "age":               28,
    "gender":            0,
    "systolic_bp":       112,
    "diastolic_bp":      72,
    "total_cholesterol": 165,
    "ldl_cholesterol":   90,
    "hdl_cholesterol":   65,
    "smoking_status":    "non-smoker",
    "stress_level":      2,
    "physical_activity": 3,
    "has_diabetes":      0,
    "has_family_history":0,
    "has_hypertension":  0,
    "obesity":           0,
}
r = requests.post(f"{BASE_URL}/predict", json=low_risk)
result = r.json()
print(f"  Risk: {result['risk_percent']}%")
print(f"  Confidence: {result['confidence']}%")
print(f"  Top factor: {result['shap_factors'][0]['display_name']} — {result['shap_factors'][0]['impact_percent']}%")
print()

print("✅ All tests passed.")