from fastapi import FastAPI, Query, APIRouter
from app.clients import java_api
from app.services import stats
from datetime import datetime, date
import pandas as pd

app = FastAPI(
    title="API PetDex - Estatísticas",
    description="API para exibir dados e estatísticas dos batimentos cardíacos dos animais monitorados pela coleira inteligente",
    version="1.0.0"
)

@app.get("/batimentos", tags=["Batimentos"])
async def get_batimentos():
    dados = await java_api.buscar_todos_batimentos()
    return {"dados": dados}

@app.get("/batimentos/estatisticas", tags=["Batimentos"])
async def get_estatisticas():
    dados = await java_api.buscar_todos_batimentos()
    print(f"Total de batimentos carregados: {len(dados)}")
    resultado = stats.calcular_estatisticas(dados)
    return resultado


@app.get("/batimentos/media-por-data", tags=["Batimentos"])
async def media_batimentos_por_data(
    inicio: date = Query(..., description="Data de início no formato YYYY-MM-DD"),
    fim: date = Query(..., description="Data de fim no formato YYYY-MM-DD")
):
    dados = await java_api.buscar_todos_batimentos()
    resultado = stats.media_por_intervalo(dados, inicio, fim)
    return resultado

@app.get("/batimentos/probabilidade", tags=["Batimentos"])
async def probabilidade_batimento(valor: int = Query(..., gt=0)):
    dados = await java_api.buscar_todos_batimentos()
    valores = [bat["frequenciaMedia"] for bat in dados if isinstance(bat.get("frequenciaMedia"), (int, float))]
    
    if not valores:
        return {"erro": "Nenhum dado de batimentos disponível para análise."}

    resultado = stats.calcular_probabilidade(valor, valores)
    return resultado


@app.get("/health", tags=["Status"])
async def health_check():
    return {"status": "Ok"}

@app.get("/batimentos/media-ultimos-5-dias", tags=["Batimentos"])
async def media_batimentos_ultimos_5_dias():
    batimentos = await java_api.buscar_todos_batimentos()

    print(batimentos[:5])

    if not batimentos:
        return {"medias": {}}

    medias = stats.media_ultimos_5_dias_validos(batimentos)
    return {"medias": medias}


@app.get("/batimentos/media-ultimas-5-horas-registradas", tags=["Batimentos"])
async def media_batimentos_ultimas_5_horas():
    dados = await java_api.buscar_todos_batimentos()
    resultado = stats.media_ultimas_5_horas_registradas(dados)
    return resultado


@app.get("/batimentos/regressao", tags=["Batimentos"])
async def analise_regressao_batimentos():
    batimentos = await java_api.buscar_todos_batimentos()
    movimentos = await java_api.buscar_todos_movimentos()

    if not batimentos or not movimentos:
        return {"erro": "Dados insuficientes para análise."}

    resultado = stats.executar_regressao(batimentos, movimentos)
    return resultado

@app.get("/batimentos/predizer", tags=["Batimentos"])
async def predizer_batimento(
    acelerometroX: float = Query(...),
    acelerometroY: float = Query(...),
    acelerometroZ: float = Query(...)
):
    batimentos = await java_api.buscar_todos_batimentos()
    movimentos = await java_api.buscar_todos_movimentos()

    if not batimentos or not movimentos:
        return {"erro": "Dados insuficientes para gerar o modelo de regressão."}

    resultado = stats.executar_regressao(batimentos, movimentos)

    coef = resultado["coeficientes"]
    intercepto = resultado["coeficiente_geral"]
    padronizacao = resultado["padronizacao"]

    # Aplica padronização manualmente
    medias = padronizacao["media"]
    desvios = padronizacao["desvio"]

    # Padroniza entrada
    entrada_padronizada = {
        "acelerometroX": (acelerometroX - medias[0]) / desvios[0],
        "acelerometroY": (acelerometroY - medias[1]) / desvios[1],
        "acelerometroZ": (acelerometroZ - medias[2]) / desvios[2]
    }

    frequencia_prevista = (
        intercepto
        + coef["acelerometroX"] * entrada_padronizada["acelerometroX"]
        + coef["acelerometroY"] * entrada_padronizada["acelerometroY"]
        + coef["acelerometroZ"] * entrada_padronizada["acelerometroZ"]
    )

    return {
        "frequencia_prevista": round(frequencia_prevista, 2),
        "funcao_usada": resultado["funcao_regressao"],
    }