import pandas as pd
import joblib

from sklearn.metrics import mean_absolute_error, r2_score

# =========================
# CARREGAR MODELO
# =========================
model = joblib.load("models/price_model.pkl")

# =========================
# CARREGAR DADOS
# =========================
df = pd.read_csv("data/prices.csv")

# =========================
# FEATURES (MESMA DO TREINO)
# =========================
X = df.drop(columns=["preco"])
y = df["preco"]

# =========================
# PREVISÃO
# =========================
y_pred = model.predict(X)

# =========================
# MÉTRICAS
# =========================
mae = mean_absolute_error(y, y_pred)
r2 = r2_score(y, y_pred)

print("📊 Avaliação do Modelo")
print("----------------------")
print("Erro médio (MAE):", mae)
print("R2 Score:", r2)

# =========================
# INTERPRETAÇÃO
# =========================
if r2 > 0.8:
    print("🔥 Modelo excelente")
elif r2 > 0.6:
    print("⚠️ Modelo bom, pode melhorar")
else:
    print("❌ Modelo fraco, precisa mais dados")