import joblib
import pandas as pd

model = joblib.load("models/demand_model.pkl")

def predict_demand(days=30):

    future = model.make_future_dataframe(periods=days)

    forecast = model.predict(future)

    result = forecast[["ds", "yhat"]].tail(days)

    return {
        "previsao_demanda": result.to_dict(orient="records")
    }