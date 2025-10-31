from pydantic import BaseModel, Field
from typing import Optional, Dict, Any


class EstatisticasBatimentos(BaseModel):
    """
    Estatísticas gerais dos batimentos cardíacos de um animal.
    
    Contém medidas estatísticas descritivas calculadas a partir dos dados de batimentos
    coletados pela coleira inteligente.
    """
    media: Optional[float] = Field(
        ...,
        description="Média aritmética dos batimentos cardíacos em BPM",
        example=72.5
    )
    mediana: Optional[float] = Field(
        ...,
        description="Valor mediano dos batimentos cardíacos em BPM",
        example=71.0
    )
    moda: Optional[float] = Field(
        ...,
        description="Valor mais frequente dos batimentos cardíacos em BPM",
        example=70.0
    )
    desvio_padrao: Optional[float] = Field(
        ...,
        description="Desvio padrão dos batimentos cardíacos em BPM",
        example=8.3
    )
    assimetria: Optional[float] = Field(
        ...,
        description="Coeficiente de assimetria (skewness) da distribuição",
        example=0.25
    )
    curtose: Optional[float] = Field(
        ...,
        description="Coeficiente de curtose (kurtosis) da distribuição",
        example=-0.15
    )

    class Config:
        schema_extra = {
            "example": {
                "media": 72.5,
                "mediana": 71.0,
                "moda": 70.0,
                "desvio_padrao": 8.3,
                "assimetria": 0.25,
                "curtose": -0.15
            }
        }


class MediaPorIntervalo(BaseModel):
    """
    Média de batimentos em um intervalo de datas específico.
    """
    media: Optional[int] = Field(
        ...,
        description="Média de batimentos cardíacos no intervalo especificado em BPM",
        example=72
    )

    class Config:
        schema_extra = {
            "example": {
                "media": 72
            }
        }


class ProbabilidadeBatimento(BaseModel):
    """
    Análise de probabilidade de um valor de batimento ocorrer.
    
    Fornece uma avaliação estatística sobre a probabilidade de um determinado valor
    de batimento cardíaco ocorrer com base no histórico do animal.
    """
    valor_informado: int = Field(
        ...,
        description="Valor de batimento informado para análise em BPM",
        example=85
    )
    media_registrada: int = Field(
        ...,
        description="Média de batimentos registrados no histórico em BPM",
        example=72
    )
    desvio_padrao: int = Field(
        ...,
        description="Desvio padrão dos batimentos registrados em BPM",
        example=8
    )
    probabilidade_percentual: float = Field(
        ...,
        description="Probabilidade percentual do valor ocorrer",
        example=15.87
    )
    classificacao: str = Field(
        ...,
        description="Classificação do batimento em relação ao padrão normal",
        example="Ligeiramente incomum"
    )
    titulo: str = Field(
        ...,
        description="Título descritivo da análise com emoji",
        example="Batimento um pouco fora do comum ⚠️"
    )
    interpretacao: str = Field(
        ...,
        description="Interpretação detalhada da análise",
        example="O valor de 85 BPM é um pouco diferente da média recente. A chance de ocorrer é de aproximadamente 15.87%. Não é necessário se preocupar, mas observe o comportamento do seu pet."
    )
    avaliacao: str = Field(
        ...,
        description="Avaliação geral do batimento",
        example="O valor de 85 BPM é um pouco diferente da média recente. A chance de ocorrer é de aproximadamente 15.87%. Não é necessário se preocupar, mas observe o comportamento do seu pet."
    )

    class Config:
        schema_extra = {
            "example": {
                "valor_informado": 85,
                "media_registrada": 72,
                "desvio_padrao": 8,
                "probabilidade_percentual": 15.87,
                "classificacao": "Ligeiramente incomum",
                "titulo": "Batimento um pouco fora do comum ⚠️",
                "interpretacao": "O valor de 85 BPM é um pouco diferente da média recente. A chance de ocorrer é de aproximadamente 15.87%. Não é necessário se preocupar, mas observe o comportamento do seu pet.",
                "avaliacao": "O valor de 85 BPM é um pouco diferente da média recente. A chance de ocorrer é de aproximadamente 15.87%. Não é necessário se preocupar, mas observe o comportamento do seu pet."
            }
        }


class AnaliseBatimentoUltimo(BaseModel):
    """
    Análise do último batimento registrado.
    
    Fornece uma avaliação estatística do último batimento coletado pela coleira.
    """
    valor_informado: int = Field(
        ...,
        description="Valor do último batimento registrado em BPM",
        example=78
    )
    media_registrada: int = Field(
        ...,
        description="Média de batimentos registrados no histórico em BPM",
        example=72
    )
    desvio_padrao: int = Field(
        ...,
        description="Desvio padrão dos batimentos registrados em BPM",
        example=8
    )
    probabilidade_percentual: float = Field(
        ...,
        description="Probabilidade percentual do valor ocorrer",
        example=30.85
    )
    classificacao: str = Field(
        ...,
        description="Classificação do batimento em relação ao padrão normal",
        example="Dentro do esperado"
    )
    titulo: str = Field(
        ...,
        description="Título descritivo da análise com emoji",
        example="Batimento esperado ✅"
    )
    interpretacao: str = Field(
        ...,
        description="Interpretação detalhada da análise",
        example="O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias."
    )
    batimento_analisado: str = Field(
        ...,
        description="Representação do batimento analisado",
        example="78 BPM"
    )
    avaliacao: str = Field(
        ...,
        description="Avaliação geral do batimento",
        example="O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias."
    )

    class Config:
        schema_extra = {
            "example": {
                "valor_informado": 78,
                "media_registrada": 72,
                "desvio_padrao": 8,
                "probabilidade_percentual": 30.85,
                "classificacao": "Dentro do esperado",
                "titulo": "Batimento esperado ✅",
                "interpretacao": "O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias.",
                "batimento_analisado": "78 BPM",
                "avaliacao": "O valor do último batimento coletado está dentro do comportamento normal observado nos últimos dias."
            }
        }


class MediaUltimos5Dias(BaseModel):
    """
    Médias de batimentos dos últimos 5 dias válidos.
    """
    medias: Dict[str, int] = Field(
        ...,
        description="Dicionário com as médias de batimentos por data (formato YYYY-MM-DD)",
        example={
            "2024-01-15": 70,
            "2024-01-16": 72,
            "2024-01-17": 71,
            "2024-01-18": 73,
            "2024-01-19": 72
        }
    )

    class Config:
        schema_extra = {
            "example": {
                "medias": {
                    "2024-01-15": 70,
                    "2024-01-16": 72,
                    "2024-01-17": 71,
                    "2024-01-18": 73,
                    "2024-01-19": 72
                }
            }
        }


class MediaUltimas5Horas(BaseModel):
    """
    Média de batimentos das últimas 5 horas registradas.
    """
    media: int = Field(
        ...,
        description="Média geral de batimentos das últimas 5 horas em BPM",
        example=71
    )
    media_por_hora: Dict[str, int] = Field(
        ...,
        description="Dicionário com as médias de batimentos por hora (formato ISO 8601)",
        example={
            "2024-01-19T14:00:00": 70,
            "2024-01-19T15:00:00": 72,
            "2024-01-19T16:00:00": 71,
            "2024-01-19T17:00:00": 73,
            "2024-01-19T18:00:00": 70
        }
    )

    class Config:
        schema_extra = {
            "example": {
                "media": 71,
                "media_por_hora": {
                    "2024-01-19T14:00:00": 70,
                    "2024-01-19T15:00:00": 72,
                    "2024-01-19T16:00:00": 71,
                    "2024-01-19T17:00:00": 73,
                    "2024-01-19T18:00:00": 70
                }
            }
        }

