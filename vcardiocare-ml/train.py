"""
train.py — VCardioCare ML Training Pipeline
Run once to train the model and save artifacts.

Usage:
    python train.py
"""

import os
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import RobustScaler
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    roc_auc_score,
)

# ── Config ──────────────────────────────────────────────
DATA_PATH    = "heart_attack_prediction_india.xlsx"
ARTIFACTS    = "artifacts"
MODEL_PATH   = os.path.join(ARTIFACTS, "model.pkl")
SCALER_PATH  = os.path.join(ARTIFACTS, "scaler.pkl")
COLS_PATH    = os.path.join(ARTIFACTS, "feature_columns.pkl")

os.makedirs(ARTIFACTS, exist_ok=True)

# ── 1. Load ──────────────────────────────────────────────
print("Loading dataset...")
df = pd.read_excel(DATA_PATH, sheet_name=0)
print(f"  Shape: {df.shape}")

# ── 2. Drop duplicates ───────────────────────────────────
df = df.drop_duplicates()

# ── 3. Drop columns not useful for prediction ────────────
drop_cols = [
    "Patient_ID",
    "Triglyceride_Level",   # dropped in your notebook too
    "State_Name",           # too many categories, low predictive value
    "Emergency_Response_Time",  # not a user health metric
    "Annual_Income",        # not collected in our app
    "Health_Insurance",     # not collected in our app
    "Healthcare_Access",    # not collected in our app
    "Air_Pollution_Exposure",   # not collected in our app
]
df = df.drop(columns=[c for c in drop_cols if c in df.columns])
print(f"  After dropping non-app columns: {df.shape}")

# ── 4. Handle missing values ─────────────────────────────
for col in df.columns:
    if df[col].isnull().sum() > 0:
        if df[col].dtype in ["float64", "int64"]:
            df[col] = df[col].fillna(df[col].median())
        else:
            df[col] = df[col].fillna(df[col].mode()[0])

# ── 5. Encode Gender (Male=1, Female=0) ──────────────────
if "Gender" in df.columns:
    df["Gender"] = df["Gender"].map({"Male": 1, "Female": 0}).fillna(0).astype(int)

# ── 6. Encode target ─────────────────────────────────────
target_col = "Heart_Attack_Risk"
if df[target_col].dtype == "object":
    df[target_col] = (
        df[target_col]
        .str.strip()
        .map({"Low": 0, "High": 1, "No": 0, "Yes": 1, "0": 0, "1": 1})
        .astype(int)
    )

print(f"  Class distribution:\n{df[target_col].value_counts()}")

# ── 7. Split features / target ───────────────────────────
X = df.drop(columns=[target_col])
y = df[target_col]

# Save exact feature column order for prediction alignment
feature_columns = X.columns.tolist()
joblib.dump(feature_columns, COLS_PATH)
print(f"\n  Features ({len(feature_columns)}): {feature_columns}")

# ── 8. Scale with RobustScaler ───────────────────────────
scaler = RobustScaler()
X_scaled = scaler.fit_transform(X)
joblib.dump(scaler, SCALER_PATH)
print("  Scaler saved.")

# ── 9. Train/test split ──────────────────────────────────
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42, stratify=y
)
print(f"\n  Train: {X_train.shape}  |  Test: {X_test.shape}")

# ── 10. Train Random Forest ──────────────────────────────
print("\nTraining Random Forest...")
model = RandomForestClassifier(
    n_estimators=200,
    max_depth=12,
    min_samples_leaf=5,
    class_weight="balanced",   # handles class imbalance
    random_state=42,
    n_jobs=-1,                 # use all CPU cores
)
model.fit(X_train, y_train)

# ── 11. Evaluate ─────────────────────────────────────────
y_pred      = model.predict(X_test)
y_prob      = model.predict_proba(X_test)[:, 1]
accuracy    = accuracy_score(y_test, y_pred)
roc_auc     = roc_auc_score(y_test, y_prob)

print(f"\n{'='*45}")
print(f"  Accuracy  : {accuracy:.4f}")
print(f"  ROC-AUC   : {roc_auc:.4f}")
print(f"\n{classification_report(y_test, y_pred)}")
print(f"Confusion Matrix:\n{confusion_matrix(y_test, y_pred)}")
print(f"{'='*45}")

# ── 12. Feature importances ──────────────────────────────
importances = (
    pd.Series(model.feature_importances_, index=feature_columns)
    .sort_values(ascending=False)
)
print(f"\nTop 10 Features:\n{importances.head(10)}")

# ── 13. Save model ───────────────────────────────────────
joblib.dump(model, MODEL_PATH)
print(f"\n✅ Model saved  → {MODEL_PATH}")
print(f"✅ Scaler saved → {SCALER_PATH}")
print(f"✅ Columns saved→ {COLS_PATH}")
print("\nTraining complete. Run: python app.py")