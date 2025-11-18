import httpx
import logging
import os
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv

# Carrega variáveis do .env
load_dotenv()

logger = logging.getLogger("PMMLPredictor")

API_BASE_URL = os.getenv("API_URL")
TOKEN_JAVA = os.getenv("JAVA_API_TOKEN")
MODEL_PATH = "modelo_CART.pmml"

# Variável global para armazenar o modelo
model = None

def _load_model():
    """Carrega o modelo PMML de forma lazy."""
    global model
    if model is None:
        try:
            # Import pypmml apenas quando necessário
            from pypmml import Model
            logger.info(f"🔄 Carregando modelo PMML: {MODEL_PATH}")
            model = Model.load(MODEL_PATH)
            logger.info(f"✅ Modelo PMML carregado com sucesso: {MODEL_PATH}")
        except Exception as e:
            logger.error(f"❌ Erro ao carregar modelo PMML: {e}")
            # Tenta carregar modelos alternativos
            alternative_models = [
                "modelo_decision_tree.pmml",
                "modelo_svm.pmml",
                "modelo_smo.pmml"
            ]
            for alt_model in alternative_models:
                try:
                    from pypmml import Model
                    logger.info(f"🔄 Tentando modelo alternativo: {alt_model}")
                    model = Model.load(alt_model)
                    logger.info(f"✅ Modelo alternativo carregado: {alt_model}")
                    break
                except Exception as alt_e:
                    logger.warning(f"⚠️ Modelo alternativo {alt_model} também falhou: {alt_e}")
                    continue

            if model is None:
                logger.error("❌ Nenhum modelo PMML pôde ser carregado")

    return model

async def get_animal_data(id_animal: str) -> dict:
    """
    Consulta os dados do animal na API Java e retorna os campos
    necessários para o modelo de predição.
    """
    url = f"{API_BASE_URL}/animais/{id_animal}"
    headers = {"Authorization": f"Bearer {TOKEN_JAVA}"}

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url, headers=headers)
            response.raise_for_status()
            data = response.json()

            logger.info(f"✅ Dados do animal obtidos: {data}")

            animal_data = {
                "tipo_do_animal": data.get("especieNome", "").lower(),
                "raca": data.get("racaNome", "").lower(),
                "idade": _calcular_idade(data.get("dataNascimento")),
                "genero": 1 if data.get("sexo") == "M" else 0,
                "peso": data.get("peso", 0),
                "batimento_cardiaco": 0  # futuro: integrar com sensores
            }

            return animal_data

    except httpx.HTTPStatusError as e:
        logger.error(f"❌ Erro HTTP {e.response.status_code} ao consultar API Java.")
    except Exception as e:
        logger.error(f"🚨 Erro geral ao consultar API Java: {e}")

    return {}

def _calcular_idade(data_nascimento: str) -> float:
    """Calcula idade aproximada em anos."""
    try:
        nascimento = datetime.fromisoformat(data_nascimento.replace("Z", "+00:00"))
        hoje = datetime.now()
        idade = (hoje - nascimento).days / 365
        return round(idade, 1)
    except Exception:
        return 0.0

# 🔮 Função principal para predição
def predict_pmml(dados: dict):
    """
    Realiza a predição usando o modelo PMML carregado.
    """
    current_model = _load_model()
    if current_model is None:
        logger.error("❌ Modelo PMML não foi carregado corretamente")
        return {"erro": "Modelo PMML não disponível"}

    try:
        df = pd.DataFrame([dados])
        result = current_model.predict(df)
        return result.to_dict(orient="records")[0]
    except Exception as e:
        logger.error(f"🚨 Erro ao realizar predição: {e}")
        return {"erro": str(e)}



def predict_with_pmml_animal(dados: dict):
    """
    Função que combina dados do animal com sintomas e realiza a predição.
    Esta é a função que está sendo chamada no main.py.
    """
    current_model = _load_model()
    if current_model is None:
        logger.error("❌ Modelo PMML não foi carregado corretamente")
        return {"erro": "Modelo PMML não disponível"}

    try:

        # Realiza a predição
        df = pd.DataFrame([dados])
        
        print(f"\nDados : {dados}")
        result = current_model.predict(df)
        
        print(f"Resultado: {result}")

        logger.info(f"✅ Predição realizada com sucesso")
        return result.to_dict(orient="records")[0]

    except Exception as e:
        logger.error(f"🚨 Erro ao realizar predição com PMML: {e}")
        return {"erro": str(e)}


def predict_with_pmml(animal_data: dict, sintomas_data: dict):
    """
    Função que combina dados do animal com sintomas e realiza a predição.
    Esta é a função que está sendo chamada no main.py.
    """
    current_model = _load_model()
    if current_model is None:
        logger.error("❌ Modelo PMML não foi carregado corretamente")
        return {"erro": "Modelo PMML não disponível"}

    try:
        # Combina dados do animal com sintomas
        dados_completos = {**animal_data, **sintomas_data}

        # Converte campos categóricos para lowercase se necessário
        if "tipo_do_animal" in dados_completos and dados_completos["tipo_do_animal"]:
            dados_completos["tipo_do_animal"] = str(dados_completos["tipo_do_animal"]).lower()
        if "raca" in dados_completos and dados_completos["raca"]:
            dados_completos["raca"] = str(dados_completos["raca"]).lower()

        # Garante que campos numéricos sejam números
        campos_numericos = ["idade", "genero", "peso", "batimento_cardiaco"]
        for campo in campos_numericos:
            if campo in dados_completos:
                try:
                    dados_completos[campo] = float(dados_completos[campo]) if dados_completos[campo] is not None else 0.0
                except (ValueError, TypeError):
                    dados_completos[campo] = 0.0

        logger.info(f"🔍 Dados para predição: {dados_completos}")

        # Realiza a predição
        df = pd.DataFrame([dados_completos])
        result = current_model.predict(df)

        logger.info(f"✅ Predição realizada com sucesso")
        return result.to_dict(orient="records")[0]

    except Exception as e:
        logger.error(f"🚨 Erro ao realizar predição com PMML: {e}")
        return {"erro": str(e)}
