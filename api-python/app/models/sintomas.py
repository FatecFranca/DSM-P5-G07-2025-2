from pydantic import BaseModel, Field
from typing import Optional


class AnimalSintomasInput(BaseModel):
    """Modelo para entrada de dados de sintomas do animal com informações demográficas"""
    tipo_do_animal: Optional[str] = Field(None, description="Tipo do animal (ex: cachorro, gato, vaca, porco)")
    raca: Optional[str] = Field(None, description="Raça do animal (ex: sem_raca_definida_(srd), pastor_alemao)")
    idade: Optional[float] = Field(None, description="Idade do animal em anos")
    genero: Optional[int] = Field(None, description="Gênero do animal (0 = fêmea, 1 = macho)")
    peso: Optional[float] = Field(None, description="Peso do animal em kg")
    batimento_cardiaco: Optional[float] = Field(None, description="Batimento cardíaco em bpm")
    duracao: Optional[float] = Field(None, description="Duração dos sintomas em dias")
    perda_de_apetite: Optional[int] = Field(None, description="Perda de apetite (0 = não, 1 = sim)")
    vomito: Optional[int] = Field(None, description="Vômito (0 = não, 1 = sim)")
    diarreia: Optional[int] = Field(None, description="Diarreia (0 = não, 1 = sim)")
    tosse: Optional[int] = Field(None, description="Tosse (0 = não, 1 = sim)")
    dificuldade_para_respirar: Optional[int] = Field(None, description="Dificuldade para respirar (0 = não, 1 = sim)")
    dificuldade_para_locomover: Optional[int] = Field(None, description="Dificuldade para locomover (0 = não, 1 = sim)")
    problemas_na_pele: Optional[int] = Field(None, description="Problemas na pele (0 = não, 1 = sim)")
    secrecao_nasal: Optional[int] = Field(None, description="Secreção nasal (0 = não, 1 = sim)")
    secrecao_ocular: Optional[int] = Field(None, description="Secreção ocular (0 = não, 1 = sim)")
    agitacao: Optional[int] = Field(None, description="Agitação (0 = não, 1 = sim)")
    andar_em_circulos: Optional[int] = Field(None, description="Andar em círculos (0 = não, 1 = sim)")
    aumento_apetite: Optional[int] = Field(None, description="Aumento de apetite (0 = não, 1 = sim)")
    cera_excessiva_nas_orelhas: Optional[int] = Field(None, description="Cera excessiva nas orelhas (0 = não, 1 = sim)")
    coceira: Optional[int] = Field(None, description="Coceira (0 = não, 1 = sim)")
    desidratacao: Optional[int] = Field(None, description="Desidratação (0 = não, 1 = sim)")
    desmaio: Optional[int] = Field(None, description="Desmaio (0 = não, 1 = sim)")
    dificuldade_para_urinar: Optional[int] = Field(None, description="Dificuldade para urinar (0 = não, 1 = sim)")
    dor: Optional[int] = Field(None, description="Dor (0 = não, 1 = sim)")
    espamos_musculares: Optional[int] = Field(None, description="Espasmos musculares (0 = não, 1 = sim)")
    espirros: Optional[int] = Field(None, description="Espirros (0 = não, 1 = sim)")
    febre: Optional[int] = Field(None, description="Febre (0 = não, 1 = sim)")
    fraqueza: Optional[int] = Field(None, description="Fraqueza (0 = não, 1 = sim)")
    inchaco: Optional[int] = Field(None, description="Inchaço (0 = não, 1 = sim)")
    lambedura: Optional[int] = Field(None, description="Lambedura excessiva (0 = não, 1 = sim)")
    letargia: Optional[int] = Field(None, description="Letargia (0 = não, 1 = sim)")
    lingua_azulada: Optional[int] = Field(None, description="Língua azulada (0 = não, 1 = sim)")
    perda_de_pelos: Optional[int] = Field(None, description="Perda de pelos (0 = não, 1 = sim)")
    perda_de_peso: Optional[int] = Field(None, description="Perda de peso (0 = não, 1 = sim)")
    ranger_de_dentes: Optional[int] = Field(None, description="Ranger de dentes (0 = não, 1 = sim)")
    ronco: Optional[int] = Field(None, description="Ronco (0 = não, 1 = sim)")
    salivacao: Optional[int] = Field(None, description="Salivação excessiva (0 = não, 1 = sim)")
    suor_alterado: Optional[int] = Field(None, description="Suor alterado (0 = não, 1 = sim)")

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
    """Modelo para entrada de dados de sintomas (sem informações demográficas) - Rota de teste"""
    duracao: Optional[float] = Field(None, description="Duração dos sintomas em dias")
    perda_de_apetite: Optional[int] = Field(None, description="Perda de apetite (0 = não, 1 = sim)")
    vomito: Optional[int] = Field(None, description="Vômito (0 = não, 1 = sim)")
    diarreia: Optional[int] = Field(None, description="Diarreia (0 = não, 1 = sim)")
    tosse: Optional[int] = Field(None, description="Tosse (0 = não, 1 = sim)")
    dificuldade_para_respirar: Optional[int] = Field(None, description="Dificuldade para respirar (0 = não, 1 = sim)")
    dificuldade_para_locomover: Optional[int] = Field(None, description="Dificuldade para locomover (0 = não, 1 = sim)")
    problemas_na_pele: Optional[int] = Field(None, description="Problemas na pele (0 = não, 1 = sim)")
    secrecao_nasal: Optional[int] = Field(None, description="Secreção nasal (0 = não, 1 = sim)")
    secrecao_ocular: Optional[int] = Field(None, description="Secreção ocular (0 = não, 1 = sim)")
    agitacao: Optional[int] = Field(None, description="Agitação (0 = não, 1 = sim)")
    andar_em_circulos: Optional[int] = Field(None, description="Andar em círculos (0 = não, 1 = sim)")
    aumento_apetite: Optional[int] = Field(None, description="Aumento de apetite (0 = não, 1 = sim)")
    cera_excessiva_nas_orelhas: Optional[int] = Field(None, description="Cera excessiva nas orelhas (0 = não, 1 = sim)")
    coceira: Optional[int] = Field(None, description="Coceira (0 = não, 1 = sim)")
    desidratacao: Optional[int] = Field(None, description="Desidratação (0 = não, 1 = sim)")
    desmaio: Optional[int] = Field(None, description="Desmaio (0 = não, 1 = sim)")
    dificuldade_para_urinar: Optional[int] = Field(None, description="Dificuldade para urinar (0 = não, 1 = sim)")
    dor: Optional[int] = Field(None, description="Dor (0 = não, 1 = sim)")
    espamos_musculares: Optional[int] = Field(None, description="Espasmos musculares (0 = não, 1 = sim)")
    espirros: Optional[int] = Field(None, description="Espirros (0 = não, 1 = sim)")
    febre: Optional[int] = Field(None, description="Febre (0 = não, 1 = sim)")
    fraqueza: Optional[int] = Field(None, description="Fraqueza (0 = não, 1 = sim)")
    inchaco: Optional[int] = Field(None, description="Inchaço (0 = não, 1 = sim)")
    lambedura: Optional[int] = Field(None, description="Lambedura excessiva (0 = não, 1 = sim)")
    letargia: Optional[int] = Field(None, description="Letargia (0 = não, 1 = sim)")
    lingua_azulada: Optional[int] = Field(None, description="Língua azulada (0 = não, 1 = sim)")
    perda_de_pelos: Optional[int] = Field(None, description="Perda de pelos (0 = não, 1 = sim)")
    perda_de_peso: Optional[int] = Field(None, description="Perda de peso (0 = não, 1 = sim)")
    ranger_de_dentes: Optional[int] = Field(None, description="Ranger de dentes (0 = não, 1 = sim)")
    ronco: Optional[int] = Field(None, description="Ronco (0 = não, 1 = sim)")
    salivacao: Optional[int] = Field(None, description="Salivação excessiva (0 = não, 1 = sim)")
    suor_alterado: Optional[int] = Field(None, description="Suor alterado (0 = não, 1 = sim)")

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