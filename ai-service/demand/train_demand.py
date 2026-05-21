import pandas as pd
import joblib
from prophet import Prophet
from sklearn.preprocessing import LabelEncoder

# =========================
# CARREGAR DADOS
# =========================
df = pd.read_csv("data/demand.csv")

# =========================
# ENCODING CATEGÓRICO
# =========================
le_produto = LabelEncoder()
le_provincia = LabelEncoder()

df["produto_enc"] = le_produto.fit_transform(df["produto"])
df["provincia_enc"] = le_provincia.fit_transform(df["provincia"])

# =========================
# CRIAR FEATURE TIME SERIES GLOBAL
# =========================
# 1. Converter para datetime explicitamente
df['date'] = pd.to_datetime(df['date'])

# 2. Agrupar apenas a coluna de demanda pela data
df_grouped = df.groupby("date")["demanda"].sum().reset_index()

# 3. Renomear para o formato do Prophet
df_grouped.columns = ['ds', 'y']

# 4. Remover linhas com valores nulos (caso existam)
df_grouped = df_grouped.dropna()

print("Colunas prontas para o Prophet:", df_grouped.columns.tolist())


# =========================
# MODELO PROPHET GLOBAL
# =========================
prophet_model = Prophet(
    yearly_seasonality=True,
    weekly_seasonality=False,
    daily_seasonality=False
)

prophet_model.fit(df_grouped)

# =========================
# SALVAR MODELO + ENCODERS
# =========================
joblib.dump(prophet_model, "models/demand_model.pkl")
joblib.dump(le_produto, "models/le_produto.pkl")
joblib.dump(le_provincia, "models/le_provincia.pkl")

print("✅ IA multi-produto e multi-província treinada")