import joblib
import pandas as pd

model = joblib.load("models/demand_model.pkl")
le_produto = joblib.load("models/le_produto.pkl")
le_provincia = joblib.load("models/le_provincia.pkl")

# =========================
# PREVISÃO GLOBAL
# =========================
def predict_global_demand(days=30):
    produtos_chave = ["Milho", "Feijão", "Arroz", "Soja", "Tomate"]
    resultados = []

    for produto in produtos_chave:
        # simulação de impacto do produto
        base = model.make_future_dataframe(periods=days)
        forecast = model.predict(base)

        multiplier = 1.0
        if produto in ["Milho", "Arroz"]:
            multiplier += 0.2
        elif produto == "Feijão":
            multiplier += 0.15
        elif produto == "Tomate":
            multiplier += 0.3
        
        forecast["yhat"] = forecast["yhat"] * multiplier
        
        # Pega o primeiro e o último dia da previsão
        yhat_hoje = forecast["yhat"].iloc[-days]
        yhat_futuro = forecast["yhat"].iloc[-1]
        
        # Calcula variação percentual
        if yhat_hoje > 0:
            variacao = ((yhat_futuro - yhat_hoje) / yhat_hoje) * 100
        else:
            variacao = 0

        resultados.append({
            "produto": produto,
            "variacao": float(variacao)
        })

    return resultados
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