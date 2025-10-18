# app/services/pmml_predictor.py
import os
import jpype
import logging
from pypmml import Model

# Configura logs para debug
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("PMMLPredictor")

# Caminho absoluto do modelo PMML
MODEL_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "modelo_smo.pmml"))

# Variável global para o modelo
model = None

def _init_model():
    """Inicializa a JVM e carrega o modelo PMML, se ainda não estiver feito."""
    global model
    if model is None:
        logger.info("🔹 Iniciando inicialização do modelo PMML...")
        try:
            if not jpype.isJVMStarted():
                logger.info("🟡 Iniciando JVM...")
                jpype.startJVM(convertStrings=False)
                logger.info("✅ JVM iniciada com sucesso!")
            else:
                logger.info("ℹ️ JVM já estava iniciada.")

            if not os.path.exists(MODEL_PATH):
                logger.error(f"❌ Arquivo de modelo não encontrado: {MODEL_PATH}")
                raise FileNotFoundError(f"Modelo PMML não encontrado em {MODEL_PATH}")

            model = Model.load(MODEL_PATH)
            logger.info(f"✅ Modelo PMML carregado com sucesso de {MODEL_PATH}")

        except Exception as e:
            logger.exception(f"🚨 Erro ao inicializar modelo PMML: {e}")
            raise

def predict_with_pmml(animal_data: dict, sintomas: dict):
    _init_model()  # Garante que a JVM e o modelo estão prontos
    input_data = {**animal_data, **sintomas}
    for k, v in input_data.items():
        if isinstance(v, str):
            input_data[k] = v.strip()
    try:
        logger.info(f"🔍 Executando predição com dados: {input_data}")
        resultado = model.predict(input_data)

        # Conversão segura para dict
        resultado_dict = {k: resultado[k] for k in resultado.keys()}
        return resultado_dict

    except Exception as e:
        logger.exception("🚨 Falha ao fazer a predição com PMML.")
        return {"erro": f"Falha ao fazer a predição com PMML: {str(e)}"}

# Teste rápido
if __name__ == "__main__":
    logger.info("🔹 Testando inicialização do modelo PMML...")
    try:
        _init_model()
        logger.info("✅ Modelo inicializado com sucesso!")

        # Exemplo de teste de predição
        teste = {
            "tipo_do_animal": "cachorro",
            "raca": "labrador",
            "idade": 3,
            "genero": "M",
            "peso": 20
        }
        sintomas = {
            "vomito": "não",
            "diarreia": "sim",
            "tosse": "não"
        }

        resultado = predict_with_pmml(teste, sintomas)
        logger.info(f"📝 Resultado da predição: {resultado}")

    except Exception as e:
        logger.error(f"🚨 Erro ao iniciar modelo: {e}")
