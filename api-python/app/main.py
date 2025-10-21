from fastapi import FastAPI, Query, HTTPException, APIRouter, Depends
from fastapi.openapi.utils import get_openapi
from app.clients import java_api
from app.services import stats
from app.security import get_current_user
from typing import Tuple
from app.services import pmml_predictor
from app.models.sintomas import AnimalSintomasInput, SintomasInput
from datetime import date, datetime
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


def custom_openapi():
    """
    Customiza o esquema OpenAPI para incluir a documentação de autenticação JWT.
    """
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="API PetDex - Estatísticas",
        version="1.0.0",
        description="""
        API para exibir dados e estatísticas dos batimentos cardíacos dos animais monitorados pela coleira inteligente.

        ## Autenticação JWT

        Esta API utiliza **JWT (JSON Web Tokens)** para autenticação. Todos os endpoints (exceto `/health`) requerem um token JWT válido.

        ### Como usar:

        1. **Obtenha um token JWT** da API Java (endpoint de login)
        2. **Inclua o token** no header `Authorization` com o formato: `Bearer <seu_token_jwt>`
        3. **Exemplo de requisição:**
           ```
           GET /batimentos/animal/123/estatisticas HTTP/1.1
           Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
           ```

        ### Respostas de erro de autenticação:

        - **401 Unauthorized**: Token ausente, inválido ou expirado
        - **401 Unauthorized**: Formato de header inválido (use `Bearer <token>`)

        ### Fluxo de autenticação:

        1. Cliente faz requisição com token JWT no header `Authorization`
        2. Python API valida o token
        3. Se válido, Python API propaga o mesmo token para a API Java
        4. Requisição é processada com o contexto de autenticação mantido
        """,
        routes=app.routes,
    )

    # Adiciona a definição de segurança Bearer (preservando os schemas existentes)
    if "components" not in openapi_schema:
        openapi_schema["components"] = {}

    if "securitySchemes" not in openapi_schema["components"]:
        openapi_schema["components"]["securitySchemes"] = {}

    openapi_schema["components"]["securitySchemes"]["Bearer"] = {
        "type": "http",
        "scheme": "bearer",
        "bearerFormat": "JWT",
        "description": "Token JWT obtido da API Java. Formato: Bearer <token>"
    }

    # Aplica a segurança Bearer a todos os endpoints (exceto /health)
    for path, path_item in openapi_schema["paths"].items():
        if path != "/health":
            for method in path_item:
                if method in ["get", "post", "put", "delete", "patch"]:
                    if "security" not in path_item[method]:
                        path_item[method]["security"] = [{"Bearer": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


def calcular_idade(data_nascimento_str: str):
    """
    Retorna a idade em anos como inteiro:
    - se idade < 1: retorna 1
    - se idade >= 1: arredonda para o inteiro mais próximo
    - em caso de data futura ou erro: retorna None
    Aceita ISO strings: "YYYY-MM-DD", "YYYY-MM-DDTHH:MM:SSZ", "+00:00" etc.
    """
    if not data_nascimento_str:
        return None
    try:
        from datetime import datetime, timezone
        import math

        # Normaliza 'Z' para '+00:00' e parse
        data_nascimento = datetime.fromisoformat(
            data_nascimento_str.replace("Z", "+00:00"))

        # Garante datetime aware em UTC
        if data_nascimento.tzinfo is None:
            data_nascimento = data_nascimento.replace(tzinfo=timezone.utc)
        else:
            data_nascimento = data_nascimento.astimezone(timezone.utc)

        hoje = datetime.now(timezone.utc)

        # Data futura => inválida
        if hoje < data_nascimento:
            return None

        # Calcula anos (mais preciso usando 365.2425 dias)
        dias = (hoje - data_nascimento).total_seconds() / 86400.0
        anos = dias / 365.2425

        if anos < 1:
            return 1

        # Arredonda para o inteiro mais próximo (0.5 -> para cima)
        return int(math.floor(anos + 0.5))
    except Exception:
        return None

# --------------------- Health ---------------------


@app.get("/health", tags=["Status"])
async def health_check():
    """
    Verifica o status da API.

    **Não requer autenticação.**

    Returns:
        dict: Status da API
    """
    return {"status": "Ok"}


# --------------------- IA (PMML) ---------------------
""" @app.post("/ia/animal/{id_animal}", tags=["IA"])
async def analisar_animal(id_animal: str, sintomas: SintomasInput):

    #Recebe sintomas e retorna a predição de problema/doença via PMML.

    response = await java_api.buscar_dados_animal(id_animal)
    if not response:
        raise HTTPException(
            status_code=404, detail="Animal não encontrado na API Java")

    resultado = pmml_predictor.predict_with_pmml(response, sintomas.dict())
    return {"animalId": id_animal, "resultado": resultado} """


@app.post("/ia/checkup/animal/{id_animal}", tags=["IA"])
async def checkup_animal(id_animal: str, sintomas: SintomasInput, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Analisa sintomas de um animal e retorna a predição de problema/doença via PMML.

    **Requer autenticação JWT.**

    ## Parâmetros:
    - **id_animal** (path): ID do animal a ser analisado
    - **sintomas** (body): Dados dos sintomas do animal (veja o schema abaixo)

    ## Retorno:
    - **animalId**: ID do animal analisado
    - **dados_entrada**: Dados combinados do animal (da API Java + sintomas)
    - **probabilidades**: Probabilidades de cada classe de doença
    - **resultado**: Nome da classe com maior probabilidade (diagnóstico previsto)

    ## Possíveis diagnósticos:
    - cardiovascular_hematologica
    - cutanea
    - gastrointestinal
    - nenhuma
    - neuro_musculoesqueletica
    - respiratoria
    - urogenital

    ## Erros:
    - **401**: Token JWT ausente, inválido ou expirado
    - **404**: Animal não encontrado na API Java
    - **500**: Erro ao processar o modelo PMML
    """
    user_id, token = credentials
    response = await java_api.buscar_dados_animal(id_animal, token)

    print(f"Response da API: \n {response}")
    if not response:
        raise HTTPException(
            status_code=404, detail="Animal não encontrado na API Java")

     # Monta dados combinados somente para inspeção / logs (o pmml_predictor aceita response + sintomas)

    # calcula idade aproximada em anos (fallback seguro caso dataNascimento falhe)
    data_nasc = response.get("dataNascimento")
    raca = response.get("racaNome")
    idade = calcular_idade(data_nasc)

    if raca == "SRD (Sem Raça Definida)":
        raca = "sem_raca_definida_(srd)"
    else:
        raca = (raca or "").lower().replace(" ", "_")
    
    dados_modelo = {
        "tipo_do_animal": (response.get("especieNome") or "").lower(),
        "raca": raca,
        "idade": idade,
        # modelo espera número (1/0) para gênero nas versões que testamos
        "genero": 1 if (response.get("sexo") or "").lower() == "m" else 0,
        "peso": response.get("peso"),
        "batimento_cardiaco": response.get("ultimo_batimento"),
        # merge só para inspeção — os sintomas reais vêm do body (SintomasInput)
        **sintomas.dict(exclude_none=True)
    }
    
    print (f"\n\nDados modelo: \n {dados_modelo}")

    # Executa a predição usando o módulo que já estava funcionando
    resultado = pmml_predictor.predict_with_pmml_animal(dados_modelo)
    
    print(f"\n\n Resultado: {resultado}")

    # Substitui todos os nan por None para evitar erro JSON
    import math
    resultado_sanitizado = {}
    classe_prevista = None
    if isinstance(resultado, dict):
        for k, v in resultado.items():
            if isinstance(v, float) and math.isnan(v):
                resultado_sanitizado[k] = None
            else:
                resultado_sanitizado[k] = v

        # Extrai a classe com maior probabilidade
        max_prob = -1
        for key, value in resultado_sanitizado.items():
            if key.startswith("probability(") and isinstance(value, (int, float)) and value is not None:
                if value > max_prob:
                    max_prob = value
                    classe_prevista = key.replace("probability(", "").replace(")", "")
    else:
        # caso o predictor retorne outro formato (string/erro), encapsula
        resultado_sanitizado = {"raw_result": resultado}

    return {"animalId": id_animal, "dados_entrada": dados_modelo, "probabilidades": resultado_sanitizado, "resultado": classe_prevista}


@app.post("/ia/checkup", tags=["IA"])
async def checkup(sintomas: AnimalSintomasInput):
    """
    Rota de teste para validar a predição da IA com base em dados diretos (sem API Java).

    **NÃO requer autenticação JWT** - Use esta rota para testar o modelo PMML.

    ## Parâmetros:
    - **sintomas** (body): Dados completos do animal com sintomas (veja o schema abaixo)

    ## Retorno:
    - **entrada**: Dados de entrada enviados
    - **probabilidades**: Probabilidades de cada classe de doença
    - **resultado**: Nome da classe com maior probabilidade (diagnóstico previsto)

    ## Possíveis diagnósticos:
    - cardiovascular_hematologica
    - cutanea
    - gastrointestinal
    - nenhuma
    - neuro_musculoesqueletica
    - respiratoria
    - urogenital

    ## Notas:
    - Ideal para testar se o modelo PMML está retornando o mesmo resultado que consta na tabela original usada no treinamento
    - Todos os campos são opcionais, mas quanto mais dados fornecidos, melhor a predição
    """
    try:
        # Converte o modelo recebido (SintomasInput) em dicionário
        dados_teste = sintomas.dict()

        # Faz a predição diretamente com o PMML
        from app.services import pmml_predictor
        resultado = pmml_predictor.predict_with_pmml({}, dados_teste)

        # Extrai a classe com maior probabilidade
        classe_prevista = None
        if isinstance(resultado, dict):
            max_prob = -1
            for key, value in resultado.items():
                if key.startswith("probability(") and isinstance(value, (int, float)) and value is not None:
                    if value > max_prob:
                        max_prob = value
                        classe_prevista = key.replace("probability(", "").replace(")", "")

        return {
            "entrada": dados_teste,
            "probabilidades": resultado,
            "resultado": classe_prevista
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro no teste de predição: {str(e)}")




# --------------------- Batimentos - Estatísticas ---------------------
@app.get("/batimentos/animal/{animalId}/estatisticas", tags=["Batimentos"])
async def get_estatisticas(animalId: str, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Obtém estatísticas gerais dos batimentos cardíacos de um animal.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal

    Returns:
        dict: Estatísticas dos batimentos (média, desvio padrão, mínimo, máximo, etc.)

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    dados = await java_api.buscar_todos_batimentos(animalId, token)
    resultado = stats.calcular_estatisticas(dados)
    return resultado

@app.get("/batimentos/animal/{animalId}/batimentos/media-por-data", tags=["Batimentos"])
async def media_batimentos_por_data(
    animalId: str,
    inicio: date = Query(..., description="Data de início YYYY-MM-DD"),
    fim: date = Query(..., description="Data de fim YYYY-MM-DD"),
    credentials: Tuple[str, str] = Depends(get_current_user)
):
    """
    Calcula a média de batimentos por data em um intervalo especificado.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal
        inicio: Data de início do intervalo (formato: YYYY-MM-DD)
        fim: Data de fim do intervalo (formato: YYYY-MM-DD)

    Returns:
        dict: Média de batimentos por data no intervalo especificado

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    dados = await java_api.buscar_todos_batimentos(animalId, token)
    resultado = stats.media_por_intervalo(dados, inicio, fim)
    return resultado

@app.get("/batimentos/animal/{animalId}/probabilidade", tags=["Batimentos"])
async def probabilidade_batimento(animalId: str, valor: int = Query(..., gt=0), credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Calcula a probabilidade de um valor de batimento ocorrer.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal
        valor: Valor de batimento para calcular a probabilidade (deve ser > 0)

    Returns:
        dict: Probabilidade do valor de batimento ocorrer

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    dados = await java_api.buscar_todos_batimentos(animalId, token)
    valores = [bat["frequenciaMedia"] for bat in dados if isinstance(bat.get("frequenciaMedia"), (int, float))]
    if not valores:
        return {"erro": "Nenhum dado de batimentos disponível."}
    resultado = stats.calcular_probabilidade(valor, valores)
    return resultado

@app.get("/batimentos/animal/{animalId}/ultimo/analise", tags=["Batimentos"])
async def probabilidade_ultimo_batimento(animalId: str, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Analisa o último batimento registrado e calcula sua probabilidade.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal

    Returns:
        dict: Análise do último batimento com sua probabilidade

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    dados = await java_api.buscar_todos_batimentos(animalId, token)
    ultimo = await java_api.buscar_ultimo_batimento(animalId, token)
    ultimo_valor = ultimo.get("frequenciaMedia") if ultimo else None

    valores = [bat["frequenciaMedia"] for bat in dados if isinstance(bat.get("frequenciaMedia"), (int, float))]
    if not valores:
        return {"erro": "Nenhum dado de batimentos disponível."}
    if ultimo_valor is None:
        return {"erro": "Não foi possível obter o último batimento"}

    resultado = stats.calcular_probabilidade_ultimo_batimento(ultimo_valor, valores)
    return resultado

@app.get("/batimentos/animal/{animalId}/media-ultimos-5-dias", tags=["Batimentos"])
async def media_batimentos_ultimos_5_dias(animalId: str, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Calcula a média de batimentos dos últimos 5 dias válidos.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal

    Returns:
        dict: Dicionário com as médias de batimentos dos últimos 5 dias

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    batimentos = await java_api.buscar_todos_batimentos(animalId, token)
    if not batimentos:
        return {"medias": {}}
    medias = stats.media_ultimos_5_dias_validos(batimentos)
    return {"medias": medias}

@app.get("/batimentos/animal/{animalId}/media-ultimas-5-horas-registradas", tags=["Batimentos"])
async def media_batimentos_ultimas_5_horas(animalId: str, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Calcula a média de batimentos das últimas 5 horas registradas.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal

    Returns:
        dict: Média de batimentos das últimas 5 horas registradas

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    dados = await java_api.buscar_todos_batimentos(animalId, token)
    resultado = stats.media_ultimas_5_horas_registradas(dados)
    return resultado


# --------------------- Batimentos - Regressão ---------------------
@app.get("/batimentos/animal/{animalId}/regressao", tags=["Batimentos"])
async def analise_regressao_batimentos(animalId: str, credentials: Tuple[str, str] = Depends(get_current_user)):
    """
    Realiza análise de regressão entre batimentos e movimentos.

    **Requer autenticação JWT.**

    Args:
        animalId: ID do animal

    Returns:
        dict: Resultado da análise de regressão com coeficientes e função utilizada

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    batimentos = await java_api.buscar_todos_batimentos(animalId, token)
    movimentos = await java_api.buscar_todos_movimentos(animalId, token)
    if not batimentos or not movimentos:
        return {"erro": "Dados insuficientes para análise."}
    resultado = stats.executar_regressao(batimentos, movimentos)
    return resultado

@app.get("/batimentos/animal/{animalId}/predizer", tags=["Batimentos"])
async def predizer_batimento(
    animalId: str,
    acelerometroX: float = Query(..., description="Valor do acelerômetro no eixo X"),
    acelerometroY: float = Query(..., description="Valor do acelerômetro no eixo Y"),
    acelerometroZ: float = Query(..., description="Valor do acelerômetro no eixo Z"),
    credentials: Tuple[str, str] = Depends(get_current_user)
):
    """
    Prediz a frequência de batimentos baseado em valores de aceleração.

    **Requer autenticação JWT.**

    Utiliza um modelo de regressão linear para prever a frequência cardíaca
    baseado nos valores dos acelerômetros (X, Y, Z).

    Args:
        animalId: ID do animal
        acelerometroX: Valor do acelerômetro no eixo X
        acelerometroY: Valor do acelerômetro no eixo Y
        acelerometroZ: Valor do acelerômetro no eixo Z

    Returns:
        dict: Frequência prevista e função de regressão utilizada

    Raises:
        401: Token JWT ausente, inválido ou expirado
    """
    user_id, token = credentials
    batimentos = await java_api.buscar_todos_batimentos(animalId, token)
    movimentos = await java_api.buscar_todos_movimentos(animalId, token)
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
