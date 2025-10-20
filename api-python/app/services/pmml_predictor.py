# app/services/pmml_predictor.py
import os
import jpype
import logging
from pypmml import Model

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("PMMLPredictor")

MODEL_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "modelo_random_forest.pmml"))
model = None

def _init_model():
    global model
    if model is None:
        logger.info("🔹 Inicializando modelo PMML...")
        try:
            if not jpype.isJVMStarted():
                jpype.startJVM(convertStrings=False)
            if not os.path.exists(MODEL_PATH):
                raise FileNotFoundError(f"Modelo PMML não encontrado em {MODEL_PATH}")
            model = Model.load(MODEL_PATH)
            logger.info(f"✅ Modelo carregado de {MODEL_PATH}")
        except Exception as e:
            logger.exception(f"Erro ao inicializar modelo PMML: {e}")
            raise

def predict_with_pmml(animal_data: dict, sintomas: dict):
    _init_model()
    input_data = {**animal_data, **sintomas}
    for k, v in input_data.items():
        if isinstance(v, str):
            input_data[k] = v.strip()
    try:
        resultado = model.predict(input_data)
        resultado_dict = {k: float(resultado[k]) for k in resultado.keys()}

        # Descobrir a classe com maior probabilidade
        classe_maior_prob = max(resultado_dict, key=resultado_dict.get)

        # Remove "probability(...)" para ficar só o nome da doença
        if classe_maior_prob.startswith("probability(") and classe_maior_prob.endswith(")"):
            classe_maior_prob = classe_maior_prob[len("probability("):-1]

        # Montar JSON final no mesmo formato do antigo
        final_result = {"predicted_classe_doenca": classe_maior_prob}
        for k, v in resultado_dict.items():
            if k.startswith("probability(") and k.endswith(")"):
                chave = k[len("probability("):-1]  # pega só o nome da doença
                final_result[f"probability_{chave}"] = v
        

        return final_result

    except Exception as e:
        logger.exception("Falha ao fazer predição com PMML.")
        return {"erro": f"Falha ao fazer predição com PMML: {str(e)}"}