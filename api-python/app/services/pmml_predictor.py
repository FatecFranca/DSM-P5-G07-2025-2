# app/services/pmml_predictor.py
import os
import jpype
from pypmml import Model

# Caminho absoluto do modelo PMML
MODEL_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "modelo_smo.pmml"))

# Variável global para armazenar o modelo
model = None

def _init_model():
    """Inicializa a JVM e carrega o modelo PMML, se ainda não estiver feito."""
    global model
    if model is None:
        if not jpype.isJVMStarted():
            jpype.startJVM(convertStrings=False)
        model = Model.load(MODEL_PATH)

def predict_with_pmml(animal_data: dict, sintomas: dict):
    """
    Recebe os dados do animal + sintomas e retorna a predição do modelo PMML.
    Inicializa a JVM e carrega o modelo na primeira chamada.
    """
    _init_model()  # Garante que a JVM e o modelo estão prontos

    # Combina dados do animal com os sintomas
    input_data = {**animal_data, **sintomas}
    for k, v in input_data.items():
        if isinstance(v, str):
            input_data[k] = v.strip()

    try:
        resultado = model.predict(input_data)
        return resultado.to_dict()
    except Exception as e:
        return {"erro": f"Falha ao fazer a predição com PMML: {str(e)}"}
