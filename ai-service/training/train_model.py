import pandas as pd
import joblib

from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBRegressor

# =========================
# 1. CARREGAR DADOS
# =========================
df = pd.read_csv("data/prices.csv")

# =========================
# 2. ENCODING CATEGÓRICO
# =========================
le_produto = LabelEncoder()
le_provincia = LabelEncoder()
le_clima = LabelEncoder()

df["produto"] = le_produto.fit_transform(df["produto"])
df["provincia"] = le_provincia.fit_transform(df["provincia"])
df["clima"] = le_clima.fit_transform(df["clima"])

# =========================
# 3. FEATURES
# =========================
X = df[[
    "produto",
    "provincia",
    "mes",
    "ano",
    "clima",
    "quantidade_produzida",
    "custo_transporte",
    "inflacao",
    "demanda_historica"
]]

y = df["preco"]

# =========================
# 4. SPLIT (CORRETO)
# =========================
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# =========================
# 5. MODELO (XGBOOST)
# =========================
model = XGBRegressor(
    n_estimators=300,
    learning_rate=0.05,
    max_depth=6
)

model.fit(X_train, y_train)

# =========================
# 6. AVALIAÇÃO
# =========================
y_pred = model.predict(X_test)
erro = mean_absolute_error(y_test, y_pred)

print("📊 Erro médio do modelo:", erro)

# =========================
# 7. SALVAR MODELO
# =========================
joblib.dump(model, "models/price_model.pkl")
joblib.dump(le_produto, "models/le_produto.pkl")
joblib.dump(le_provincia, "models/le_provincia.pkl")
joblib.dump(le_clima, "models/le_clima.pkl")

print("✅ Modelo treinado e salvo com sucesso")