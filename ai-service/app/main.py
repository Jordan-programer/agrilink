from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from demand.service import predict_global_demand, predict_filtered
from services.price_service import predict_price 

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/demanda/global")
def global_demand():
    return predict_global_demand()

@app.post("/demanda/filtro")
def filtered(produto: str, provincia: str):
    return predict_filtered(produto, provincia)

@app.post("/preco/previsao")
def get_price_forecast(data: dict): 
    return predict_price(data)