import httpx
import logging
import os
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from pypmml import Model

# Carrega variáveis do .env
load_dotenv()

logger = logging.getLogger("PMMLPredictor")

API_BASE_URL = os.getenv("API_URL")
TOKEN_JAVA = os.getenv("JAVA_API_TOKEN")
MODEL_PATH = "modelos/modelo_random_forest.pmml"

# ✅ Carrega o modelo uma única vez ao iniciar
model = Model.load(MODEL_PATH)

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
    try:
        df = pd.DataFrame([dados])
        result = model.predict(df)
        return result.to_dict(orient="records")[0]
    except Exception as e:
        logger.error(f"🚨 Erro ao realizar predição: {e}")
        return {"erro": str(e)}
