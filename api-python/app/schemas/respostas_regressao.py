from pydantic import BaseModel, Field
from typing import Dict, Any


class AnaliseRegressao(BaseModel):
    """
    Resultado da análise de regressão entre batimentos e movimentos.
    
    Fornece coeficientes de regressão, correlações, métricas de desempenho e
    projeções de batimentos futuros baseadas em dados de aceleração.
    """
    coeficiente_geral: float = Field(
        ...,
        description="Coeficiente de interceptação (termo independente) da função de regressão",
        example=72.5
    )
    coeficientes: Dict[str, float] = Field(
        ...,
        description="Coeficientes de regressão para cada eixo do acelerômetro",
        example={
            "acelerometroX": 0.125,
            "acelerometroY": -0.085,
            "acelerometroZ": 0.215
        }
    )
    correlacoes: Dict[str, float] = Field(
        ...,
        description="Correlação de Pearson entre cada eixo do acelerômetro e os batimentos",
        example={
            "acelerometroX": 0.342,
            "acelerometroY": -0.215,
            "acelerometroZ": 0.567
        }
    )
    r2: float = Field(
        ...,
        description="Coeficiente de determinação (R²) do modelo",
        example=0.685
    )
    media_erro_quadratico: float = Field(
        ...,
        description="Erro quadrático médio (MSE) do modelo",
        example=12.45
    )
    projecao_5_segundos: Dict[str, int] = Field(
        ...,
        description="Projeção de batimentos para os próximos 5 segundos",
        example={
            "2024-01-19T18:30:01": 73,
            "2024-01-19T18:30:02": 74,
            "2024-01-19T18:30:03": 72,
            "2024-01-19T18:30:04": 75,
            "2024-01-19T18:30:05": 73
        }
    )
    funcao_regressao: str = Field(
        ...,
        description="Função de regressão em formato legível",
        example="frequenciaMedia = 72.5 + (0.125 * acelerometroX) + (-0.085 * acelerometroY) + (0.215 * acelerometroZ)"
    )
    padronizacao: Dict[str, Any] = Field(
        ...,
        description="Parâmetros de padronização utilizados no modelo",
        example={
            "media": [0.5, 0.3, 0.2],
            "desvio": [0.15, 0.12, 0.18],
            "variaveis": ["acelerometroX", "acelerometroY", "acelerometroZ"]
        }
    )

    class Config:
        schema_extra = {
            "example": {
                "coeficiente_geral": 72.5,
                "coeficientes": {
                    "acelerometroX": 0.125,
                    "acelerometroY": -0.085,
                    "acelerometroZ": 0.215
                },
                "correlacoes": {
                    "acelerometroX": 0.342,
                    "acelerometroY": -0.215,
                    "acelerometroZ": 0.567
                },
                "r2": 0.685,
                "media_erro_quadratico": 12.45,
                "projecao_5_segundos": {
                    "2024-01-19T18:30:01": 73,
                    "2024-01-19T18:30:02": 74,
                    "2024-01-19T18:30:03": 72,
                    "2024-01-19T18:30:04": 75,
                    "2024-01-19T18:30:05": 73
                },
                "funcao_regressao": "frequenciaMedia = 72.5 + (0.125 * acelerometroX) + (-0.085 * acelerometroY) + (0.215 * acelerometroZ)",
                "padronizacao": {
                    "media": [0.5, 0.3, 0.2],
                    "desvio": [0.15, 0.12, 0.18],
                    "variaveis": ["acelerometroX", "acelerometroY", "acelerometroZ"]
                }
            }
        }


class PredicaoBatimento(BaseModel):
    """
    Predição de frequência cardíaca baseada em valores de aceleração.
    
    Utiliza o modelo de regressão linear para prever a frequência cardíaca
    a partir dos valores dos acelerômetros.
    """
    frequencia_prevista: float = Field(
        ...,
        description="Frequência cardíaca prevista em BPM",
        example=75.42
    )
    funcao_usada: str = Field(
        ...,
        description="Função de regressão utilizada para a predição",
        example="frequenciaMedia = 72.5 + (0.125 * acelerometroX) + (-0.085 * acelerometroY) + (0.215 * acelerometroZ)"
    )

    class Config:
        schema_extra = {
            "example": {
                "frequencia_prevista": 75.42,
                "funcao_usada": "frequenciaMedia = 72.5 + (0.125 * acelerometroX) + (-0.085 * acelerometroY) + (0.215 * acelerometroZ)"
            }
        }

