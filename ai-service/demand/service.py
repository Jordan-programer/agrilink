import joblib
import pandas as pd

model = joblib.load("models/demand_model.pkl")
le_produto = joblib.load("models/le_produto.pkl")
le_provincia = joblib.load("models/le_provincia.pkl")

# =========================
# PREVISÃO GLOBAL
# =========================
def predict_global_demand(days=30):

    future = model.make_future_dataframe(periods=days)
    forecast = model.predict(future)

    result = forecast[["ds", "yhat"]].tail(days)

    return {
        "demanda_global": result.to_dict(orient="records")
    }

# =========================
# PREVISÃO POR FILTRO (SIMULADO)
# =========================
def predict_filtered(produto, provincia):

    # simulação de impacto do produto/província
    base = model.make_future_dataframe(periods=30)
    forecast = model.predict(base)

    multiplier = 1.0

    if produto in ["milho", "arroz"]:
        multiplier += 0.2

    if provincia in ["Luanda"]:
        multiplier += 0.3

    forecast["yhat"] = forecast["yhat"] * multiplier

    return {
        "produto": produto,
        "provincia": provincia,
        "previsao": forecast[["ds", "yhat"]].tail(30).to_dict(orient="records")
    }