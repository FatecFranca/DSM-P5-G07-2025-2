from pydantic import BaseModel, Field
from typing import Optional, Dict, Any


class RespostaCheckupAnimal(BaseModel):
    """
    Resposta da análise de checkup de um animal com sintomas.
    
    Contém o ID do animal, dados de entrada utilizados, probabilidades de cada diagnóstico
    e o resultado final da predição.
    """
    animalId: str = Field(
        ...,
        description="Identificador único do animal analisado",
        example="123"
    )
    dados_entrada: Dict[str, Any] = Field(
        ...,
        description="Dados combinados do animal (informações demográficas + sintomas) utilizados no modelo",
        example={
            "tipo_do_animal": "cachorro",
            "raca": "sem_raca_definida_(srd)",
            "idade": 10,
            "genero": 1,
            "peso": 26.0,
            "batimento_cardiaco": 62.0,
            "duracao": 7.0,
            "perda_de_apetite": 1,
            "vomito": 1,
            "diarreia": 1,
            "desidratacao": 1,
            "dor": 1,
            "febre": 1,
            "fraqueza": 1,
            "letargia": 1
        }
    )
    probabilidades: Dict[str, Optional[float]] = Field(
        ...,
        description="Probabilidades calculadas para cada classe de diagnóstico possível",
        example={
            "probability(cardiovascular_hematologica)": 0.15,
            "probability(cutanea)": 0.05,
            "probability(gastrointestinal)": 0.65,
            "probability(nenhuma)": 0.05,
            "probability(neuro_musculoesqueletica)": 0.05,
            "probability(respiratoria)": 0.03,
            "probability(urogenital)": 0.02
        }
    )
    resultado: Optional[str] = Field(
        ...,
        description="Diagnóstico previsto (classe com maior probabilidade)",
        example="gastrointestinal"
    )

    class Config:
        schema_extra = {
            "example": {
                "animalId": "123",
                "dados_entrada": {
                    "tipo_do_animal": "cachorro",
                    "raca": "sem_raca_definida_(srd)",
                    "idade": 10,
                    "genero": 1,
                    "peso": 26.0,
                    "batimento_cardiaco": 62.0,
                    "duracao": 7.0,
                    "perda_de_apetite": 1,
                    "vomito": 1,
                    "diarreia": 1,
                    "desidratacao": 1,
                    "dor": 1,
                    "febre": 1,
                    "fraqueza": 1,
                    "letargia": 1
                },
                "probabilidades": {
                    "probability(cardiovascular_hematologica)": 0.15,
                    "probability(cutanea)": 0.05,
                    "probability(gastrointestinal)": 0.65,
                    "probability(nenhuma)": 0.05,
                    "probability(neuro_musculoesqueletica)": 0.05,
                    "probability(respiratoria)": 0.03,
                    "probability(urogenital)": 0.02
                },
                "resultado": "gastrointestinal"
            }
        }


class RespostaCheckupTeste(BaseModel):
    """
    Resposta da análise de checkup de teste (sem dados da API Java).
    
    Utilizada para validação do modelo PMML com dados diretos.
    """
    entrada: Dict[str, Any] = Field(
        ...,
        description="Dados de entrada enviados para análise",
        example={
            "duracao": 7.0,
            "perda_de_apetite": 1,
            "vomito": 1,
            "diarreia": 1,
            "desidratacao": 1,
            "dor": 1,
            "febre": 1,
            "fraqueza": 1,
            "letargia": 1
        }
    )
    probabilidades: Dict[str, Optional[float]] = Field(
        ...,
        description="Probabilidades calculadas para cada classe de diagnóstico",
        example={
            "probability(cardiovascular_hematologica)": 0.15,
            "probability(cutanea)": 0.05,
            "probability(gastrointestinal)": 0.65,
            "probability(nenhuma)": 0.05,
            "probability(neuro_musculoesqueletica)": 0.05,
            "probability(respiratoria)": 0.03,
            "probability(urogenital)": 0.02
        }
    )
    resultado: Optional[str] = Field(
        ...,
        description="Diagnóstico previsto (classe com maior probabilidade)",
        example="gastrointestinal"
    )

    class Config:
        schema_extra = {
            "example": {
                "entrada": {
                    "duracao": 7.0,
                    "perda_de_apetite": 1,
                    "vomito": 1,
                    "diarreia": 1,
                    "desidratacao": 1,
                    "dor": 1,
                    "febre": 1,
                    "fraqueza": 1,
                    "letargia": 1
                },
                "probabilidades": {
                    "probability(cardiovascular_hematologica)": 0.15,
                    "probability(cutanea)": 0.05,
                    "probability(gastrointestinal)": 0.65,
                    "probability(nenhuma)": 0.05,
                    "probability(neuro_musculoesqueletica)": 0.05,
                    "probability(respiratoria)": 0.03,
                    "probability(urogenital)": 0.02
                },
                "resultado": "gastrointestinal"
            }
        }

