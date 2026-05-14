import joblib
import pandas as pd

# =========================
# CARREGAR MODELO
# =========================
model = joblib.load("models/price_model.pkl")
le_produto = joblib.load("models/le_produto.pkl")
le_provincia = joblib.load("models/le_provincia.pkl")
le_clima = joblib.load("models/le_clima.pkl")

# =========================
# PREVISÃO PRINCIPAL
# =========================
def predict_price(data: dict):
    try:
        # Padronização automática: remove espaços e ajusta maiúsculas/minúsculas
        # De acordo com seus logs: produtos e climas são minúsculos, Províncias são Iniciais Maiúsculas
        produto_nome = str(data.get("produto", "tomate")).lower().strip()
        clima_nome = str(data.get("clima", "limpo")).lower().strip()
        provincia_nome = str(data.get("provincia", "Luanda")).strip()

        # Transformação segura
        produto_enc = le_produto.transform([produto_nome])[0]
        provincia_enc = le_provincia.transform([provincia_nome])[0]
        clima_enc = le_clima.transform([clima_nome])[0]

        mes_inicial = int(data.get("mes", 5))
        ano_atual = int(data.get("ano", 2026))

        forecast_results = []

        for i in range(6):
            futuro_mes = mes_inicial + i
            futuro_ano = ano_atual
            if futuro_mes > 12:
                futuro_mes -= 12
                futuro_ano += 1
                
            input_data = pd.DataFrame([{
                "produto": produto_enc,
                "provincia": provincia_enc,
                "mes": futuro_mes,
                "ano": futuro_ano,
                "clima": clima_enc,
                "quantidade_produzida": float(data.get("quantidade_produzida", 100.0)),
                "custo_transporte": float(data.get("custo_transporte", 50.0)),
                "inflacao": float(data.get("inflacao", 10.0)),
                "demanda_historica": float(data.get("demanda_historica", 150.0))
            }])

            preco = model.predict(input_data)[0]
            
            # Format month and short year, e.g., 05/26
            ano_curto = str(futuro_ano)[-2:]
            mes_formatado = f"{futuro_mes:02d}/{ano_curto}"
            
            forecast_results.append({
                "preco": round(float(preco), 2),
                "mes": mes_formatado
            })

        return forecast_results

    except ValueError as e:
        # Se o usuário enviar algo que não existe no modelo, o servidor retorna 
        # esta mensagem em vez de um erro 500 (Internal Server Error)
        return {"error": f"Dados não reconhecidos pelo modelo: {str(e)}"}
    except Exception as e:
        return {"error": f"Erro inesperado: {str(e)}"}



# =========================
# PREÇO SUGERIDO (NEGÓCIO)
# =========================
def suggest_price(preco_previsto, demanda, oferta):

    if demanda > oferta:
        margem = 0.25
    elif demanda < oferta:
        margem = 0.10
    else:
        margem = 0.15

    return round(preco_previsto * (1 + margem), 2)

le_produto = joblib.load("models/le_produto.pkl")
print("Produtos aceitos:", le_produto.classes_)

le_cli = joblib.load("models/le_clima.pkl")
print("Climas aceitos:", le_cli.classes_)