from pydantic import BaseModel, Field
from typing import Optional


class AnimalSintomasInput(BaseModel):
    """
    Modelo para entrada de dados de sintomas do animal com informações demográficas.

    Utilizado para análise de diagnóstico via modelo PMML, combinando dados demográficos
    do animal com sintomas clínicos observados.
    """
    tipo_do_animal: Optional[str] = Field(
        None,
        description="Tipo/espécie do animal. Exemplos: cachorro, gato, vaca, porco",
        example="cachorro"
    )
    raca: Optional[str] = Field(
        None,
        description="Raça do animal. Exemplos: sem_raca_definida_(srd), pastor_alemao, poodle",
        example="sem_raca_definida_(srd)"
    )
    idade: Optional[float] = Field(
        None,
        description="Idade do animal em anos",
        example=10.5
    )
    genero: Optional[int] = Field(
        None,
        description="Gênero do animal. **Valores disponíveis** - 0 (fêmea), 1 (macho)",
        example=1
    )
    peso: Optional[float] = Field(
        None,
        description="Peso do animal em quilogramas (kg)",
        example=26.0
    )
    batimento_cardiaco: Optional[float] = Field(
        None,
        description="Frequência cardíaca do animal em batimentos por minuto (BPM)",
        example=62.0
    )
    duracao: Optional[float] = Field(
        None,
        description="Duração dos sintomas em dias",
        example=7.0
    )
    perda_de_apetite: Optional[int] = Field(
        None,
        description="Presença de perda de apetite. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    vomito: Optional[int] = Field(
        None,
        description="Presença de vômito. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    diarreia: Optional[int] = Field(
        None,
        description="Presença de diarreia. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    tosse: Optional[int] = Field(
        None,
        description="Presença de tosse. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_respirar: Optional[int] = Field(
        None,
        description="Presença de dificuldade para respirar. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_locomover: Optional[int] = Field(
        None,
        description="Presença de dificuldade para locomover. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    problemas_na_pele: Optional[int] = Field(
        None,
        description="Presença de problemas na pele. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    secrecao_nasal: Optional[int] = Field(
        None,
        description="Presença de secreção nasal. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    secrecao_ocular: Optional[int] = Field(
        None,
        description="Presença de secreção ocular. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    agitacao: Optional[int] = Field(
        None,
        description="Presença de agitação. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    andar_em_circulos: Optional[int] = Field(
        None,
        description="Presença de andar em círculos. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    aumento_apetite: Optional[int] = Field(
        None,
        description="Presença de aumento de apetite. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    cera_excessiva_nas_orelhas: Optional[int] = Field(
        None,
        description="Presença de cera excessiva nas orelhas. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    coceira: Optional[int] = Field(
        None,
        description="Presença de coceira. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    desidratacao: Optional[int] = Field(
        None,
        description="Presença de desidratação. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    desmaio: Optional[int] = Field(
        None,
        description="Presença de desmaio. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_urinar: Optional[int] = Field(
        None,
        description="Presença de dificuldade para urinar. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dor: Optional[int] = Field(
        None,
        description="Presença de dor. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    espamos_musculares: Optional[int] = Field(
        None,
        description="Presença de espasmos musculares. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    espirros: Optional[int] = Field(
        None,
        description="Presença de espirros. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    febre: Optional[int] = Field(
        None,
        description="Presença de febre. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    fraqueza: Optional[int] = Field(
        None,
        description="Presença de fraqueza. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    inchaco: Optional[int] = Field(
        None,
        description="Presença de inchaço. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    lambedura: Optional[int] = Field(
        None,
        description="Presença de lambedura excessiva. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    letargia: Optional[int] = Field(
        None,
        description="Presença de letargia. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    lingua_azulada: Optional[int] = Field(
        None,
        description="Presença de língua azulada. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    perda_de_pelos: Optional[int] = Field(
        None,
        description="Presença de perda de pelos. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    perda_de_peso: Optional[int] = Field(
        None,
        description="Presença de perda de peso. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    ranger_de_dentes: Optional[int] = Field(
        None,
        description="Presença de ranger de dentes. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    ronco: Optional[int] = Field(
        None,
        description="Presença de ronco. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    salivacao: Optional[int] = Field(
        None,
        description="Presença de salivação excessiva. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    suor_alterado: Optional[int] = Field(
        None,
        description="Presença de suor alterado. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )

    class Config:
        schema_extra = {
            "example": {
                "tipo_do_animal": "cachorro",
                "raca": "sem_raca_definida_(srd)",
                "idade": 10.5,
                "genero": 1,
                "peso": 26,
                "batimento_cardiaco": 62,
                "duracao": 7,
                "perda_de_apetite": 1,
                "vomito": 1,
                "diarreia": 1,
                "desidratacao": 1,
                "dor": 1,
                "febre": 1,
                "fraqueza": 1,
                "letargia": 1
            }
        }

class SintomasInput(BaseModel):
    """
    Modelo para entrada de dados de sintomas (sem informações demográficas).

    Utilizado para testes de predição do modelo PMML sem necessidade de dados demográficos
    do animal. Ideal para validação e testes do modelo.
    """
    duracao: Optional[float] = Field(
        None,
        description="Duração dos sintomas em dias",
        example=7.0
    )
    perda_de_apetite: Optional[int] = Field(
        None,
        description="Presença de perda de apetite. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    vomito: Optional[int] = Field(
        None,
        description="Presença de vômito. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    diarreia: Optional[int] = Field(
        None,
        description="Presença de diarreia. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    tosse: Optional[int] = Field(
        None,
        description="Presença de tosse. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_respirar: Optional[int] = Field(
        None,
        description="Presença de dificuldade para respirar. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_locomover: Optional[int] = Field(
        None,
        description="Presença de dificuldade para locomover. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    problemas_na_pele: Optional[int] = Field(
        None,
        description="Presença de problemas na pele. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    secrecao_nasal: Optional[int] = Field(
        None,
        description="Presença de secreção nasal. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    secrecao_ocular: Optional[int] = Field(
        None,
        description="Presença de secreção ocular. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    agitacao: Optional[int] = Field(
        None,
        description="Presença de agitação. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    andar_em_circulos: Optional[int] = Field(
        None,
        description="Presença de andar em círculos. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    aumento_apetite: Optional[int] = Field(
        None,
        description="Presença de aumento de apetite. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    cera_excessiva_nas_orelhas: Optional[int] = Field(
        None,
        description="Presença de cera excessiva nas orelhas. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    coceira: Optional[int] = Field(
        None,
        description="Presença de coceira. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    desidratacao: Optional[int] = Field(
        None,
        description="Presença de desidratação. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    desmaio: Optional[int] = Field(
        None,
        description="Presença de desmaio. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dificuldade_para_urinar: Optional[int] = Field(
        None,
        description="Presença de dificuldade para urinar. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    dor: Optional[int] = Field(
        None,
        description="Presença de dor. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    espamos_musculares: Optional[int] = Field(
        None,
        description="Presença de espasmos musculares. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    espirros: Optional[int] = Field(
        None,
        description="Presença de espirros. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    febre: Optional[int] = Field(
        None,
        description="Presença de febre. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    fraqueza: Optional[int] = Field(
        None,
        description="Presença de fraqueza. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    inchaco: Optional[int] = Field(
        None,
        description="Presença de inchaço. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    lambedura: Optional[int] = Field(
        None,
        description="Presença de lambedura excessiva. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    letargia: Optional[int] = Field(
        None,
        description="Presença de letargia. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=1
    )
    lingua_azulada: Optional[int] = Field(
        None,
        description="Presença de língua azulada. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    perda_de_pelos: Optional[int] = Field(
        None,
        description="Presença de perda de pelos. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    perda_de_peso: Optional[int] = Field(
        None,
        description="Presença de perda de peso. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    ranger_de_dentes: Optional[int] = Field(
        None,
        description="Presença de ranger de dentes. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    ronco: Optional[int] = Field(
        None,
        description="Presença de ronco. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    salivacao: Optional[int] = Field(
        None,
        description="Presença de salivação excessiva. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )
    suor_alterado: Optional[int] = Field(
        None,
        description="Presença de suor alterado. **Valores disponíveis** - 0 (não), 1 (sim)",
        example=0
    )

    class Config:
        schema_extra = {
            "example": {
                "duracao": 7,
                "perda_de_apetite": 1,
                "vomito": 1,
                "diarreia": 1,
                "desidratacao": 1,
                "dor": 1,
                "febre": 1,
                "fraqueza": 1,
                "letargia": 1
            }
        }