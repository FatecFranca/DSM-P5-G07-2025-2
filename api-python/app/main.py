from fastapi import FastAPI, Query, HTTPException, APIRouter
from app.clients import java_api
from app.services import stats
from app.services import pmml_predictor
from app.models.sintomas import SintomasInput
from datetime import date
from pydantic import BaseModel
from typing import Optional
import math
import os

app = FastAPI(
    title="API PetDex - Estatísticas",
    description="API para exibir dados e estatísticas dos batimentos cardíacos dos animais monitorados pela coleira inteligente",
    version="1.0.0"
)
API_URL = os.getenv("API_URL")

# --------------------- Health ---------------------
@app.get("/health", tags=["Status"])
async def health_check():
    return {"status": "Ok"}


# --------------------- IA (PMML) ---------------------
""" @app.post("/ia/animal/{id_animal}", tags=["IA"])
async def analisar_animal(id_animal: str, sintomas: SintomasInput):
  
    #Recebe sintomas e retorna a predição de problema/doença via PMML.
    
    response = await java_api.buscar_dados_animal(id_animal)
    if not response:
        raise HTTPException(status_code=404, detail="Animal não encontrado na API Java")
    
    resultado = pmml_predictor.predict_with_pmml(response, sintomas.dict())
    return {"animalId": id_animal, "resultado": resultado} """

@app.post("/ia/animal/{id_animal}", tags=["IA"])
async def analisar_animal(id_animal: str, sintomas: SintomasInput):
    
    #Recebe sintomas e retorna a predição de problema/doença via PMML.
    
    response = await java_api.buscar_dados_animal(id_animal)
    if not response:
        raise HTTPException(status_code=404, detail="Animal não encontrado na API Java")
    
    resultado = pmml_predictor.predict_with_pmml(response, sintomas.dict())
    
    # Substitui todos os nan por None
    resultado_sanitizado = {k: (None if isinstance(v, float) and math.isnan(v) else v) for k, v in resultado.items()}
    
    return {"animalId": id_animal, "resultado": resultado_sanitizado}


# --------------------- Batimentos - Estatísticas ---------------------
@app.get("/batimentos/animal/{animalId}/estatisticas", tags=["Batimentos"])
async def get_estatisticas(animalId: str):
    dados = await java_api.buscar_todos_batimentos(animalId)
    resultado = stats.calcular_estatisticas(dados)
    return resultado

@app.get("/batimentos/animal/{animalId}/batimentos/media-por-data", tags=["Batimentos"])
async def media_batimentos_por_data(
    animalId: str,
    inicio: date = Query(..., description="Data de início YYYY-MM-DD"),
    fim: date = Query(..., description="Data de fim YYYY-MM-DD")
):
    dados = await java_api.buscar_todos_batimentos(animalId)
    resultado = stats.media_por_intervalo(dados, inicio, fim)
    return resultado

@app.get("/batimentos/animal/{animalId}/probabilidade", tags=["Batimentos"])
async def probabilidade_batimento(animalId: str, valor: int = Query(..., gt=0)):
    dados = await java_api.buscar_todos_batimentos(animalId)
    valores = [bat["frequenciaMedia"] for bat in dados if isinstance(bat.get("frequenciaMedia"), (int, float))]
    if not valores:
        return {"erro": "Nenhum dado de batimentos disponível."}
    resultado = stats.calcular_probabilidade(valor, valores)
    return resultado

@app.get("/batimentos/animal/{animalId}/ultimo/analise", tags=["Batimentos"])
async def probabilidade_ultimo_batimento(animalId: str):
    dados = await java_api.buscar_todos_batimentos(animalId)
    ultimo = await java_api.buscar_ultimo_batimento(animalId)
    ultimo_valor = ultimo.get("frequenciaMedia") if ultimo else None

    valores = [bat["frequenciaMedia"] for bat in dados if isinstance(bat.get("frequenciaMedia"), (int, float))]
    if not valores:
        return {"erro": "Nenhum dado de batimentos disponível."}
    if ultimo_valor is None:
        return {"erro": "Não foi possível obter o último batimento"}

    resultado = stats.calcular_probabilidade_ultimo_batimento(ultimo_valor, valores)
    return resultado

@app.get("/batimentos/animal/{animalId}/media-ultimos-5-dias", tags=["Batimentos"])
async def media_batimentos_ultimos_5_dias(animalId: str):
    batimentos = await java_api.buscar_todos_batimentos(animalId)
    if not batimentos:
        return {"medias": {}}
    medias = stats.media_ultimos_5_dias_validos(batimentos)
    return {"medias": medias}

@app.get("/batimentos/animal/{animalId}/media-ultimas-5-horas-registradas", tags=["Batimentos"])
async def media_batimentos_ultimas_5_horas(animalId: str):
    dados = await java_api.buscar_todos_batimentos(animalId)
    resultado = stats.media_ultimas_5_horas_registradas(dados)
    return resultado


# --------------------- Batimentos - Regressão ---------------------
@app.get("/batimentos/animal/{animalId}/regressao", tags=["Batimentos"])
async def analise_regressao_batimentos(animalId: str):
    batimentos = await java_api.buscar_todos_batimentos(animalId)
    movimentos = await java_api.buscar_todos_movimentos(animalId)
    if not batimentos or not movimentos:
        return {"erro": "Dados insuficientes para análise."}
    resultado = stats.executar_regressao(batimentos, movimentos)
    return resultado

@app.get("/batimentos/animal/{animalId}/predizer", tags=["Batimentos"])
async def predizer_batimento(
    animalId: str,
    acelerometroX: float = Query(...),
    acelerometroY: float = Query(...),
    acelerometroZ: float = Query(...)
):
    batimentos = await java_api.buscar_todos_batimentos(animalId)
    movimentos = await java_api.buscar_todos_movimentos(animalId)
    if not batimentos or not movimentos:
        return {"erro": "Dados insuficientes para gerar o modelo de regressão."}

    resultado = stats.executar_regressao(batimentos, movimentos)
    coef = resultado["coeficientes"]
    intercepto = resultado["coeficiente_geral"]
    padronizacao = resultado["padronizacao"]

    entrada_padronizada = {
        "acelerometroX": (acelerometroX - padronizacao["media"][0]) / padronizacao["desvio"][0],
        "acelerometroY": (acelerometroY - padronizacao["media"][1]) / padronizacao["desvio"][1],
        "acelerometroZ": (acelerometroZ - padronizacao["media"][2]) / padronizacao["desvio"][2]
    }

    frequencia_prevista = (
        intercepto
        + coef["acelerometroX"] * entrada_padronizada["acelerometroX"]
        + coef["acelerometroY"] * entrada_padronizada["acelerometroY"]
        + coef["acelerometroZ"] * entrada_padronizada["acelerometroZ"]
    )

    return {"frequencia_prevista": round(frequencia_prevista, 2), "funcao_usada": resultado["funcao_regressao"]}
