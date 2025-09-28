import pandas as pd
from statistics import mean, stdev
from scipy.stats import skew, norm, kurtosis
import numpy as np
import scipy.stats as stats
from typing import List, Dict
from datetime import datetime, timedelta, timezone, date
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from scipy.stats import pearsonr
from sklearn.preprocessing import StandardScaler
from datetime import timedelta


def calcular_estatisticas(dados: List[dict]) -> dict:
    df = pd.DataFrame(dados)
    df["frequenciaMedia"] = pd.to_numeric(df["frequenciaMedia"], errors="coerce")
    valores = df["frequenciaMedia"].dropna()
    valores = valores[(valores >= 30) & (valores <= 200)]
    print(f"Total bruto: {len(df)} | Após filtro de faixa: {len(valores)}")

    media = valores.mean()
    desvio = valores.std()

    if desvio > 0:
        limite_inferior = media - 3 * desvio
        limite_superior = media + 3 * desvio
        valores = valores[(valores >= limite_inferior) & (valores <= limite_superior)]

    if valores.empty:
        return {
            "media": None,
            "mediana": None,
            "moda": None,
            "desvio_padrao": None,
            "assimetria": None,
            "curtose": None
        }

    return {
        "media": float(valores.mean()),
        "mediana": float(valores.median()),
        "moda": float(valores.mode().iloc[0]) if not valores.mode().empty else None,
        "desvio_padrao": float(valores.std()),
        "assimetria": float(skew(valores, bias=False)),
        "curtose": float(kurtosis(valores, bias=False))
    }

def media_por_intervalo(dados: List[dict], inicio: date, fim: date) -> Dict:
    if not dados:
        return {"media": None, "mensagem": "Nenhum dado disponível."}

    df = pd.DataFrame(dados)

    if 'data' not in df.columns or 'frequenciaMedia' not in df.columns:
        return {"media": None, "mensagem": "Colunas esperadas não encontradas."}

    df['data'] = pd.to_datetime(df['data'], errors='coerce').dt.date
    df['frequenciaMedia'] = pd.to_numeric(df['frequenciaMedia'], errors='coerce')

    df = df.dropna(subset=['data', 'frequenciaMedia'])

    df_filtrado = df[(df['data'] >= inicio) & (df['data'] <= fim)]

    if df_filtrado.empty:
        return {"media": None, "mensagem": "Nenhum dado encontrado para o intervalo fornecido."}

    media = df_filtrado['frequenciaMedia'].mean().round(2)
    return {"media": media}


def calcular_probabilidade(valor: int, dados: list):
    valores_validos = [v for v in dados if isinstance(v, (int, float)) and 20 <= v <= 200]

    if not valores_validos:
        return {
            "erro": "Não há dados suficientes dentro da faixa fisiológica (20 a 200 BPM) para análise."
        }

    media = np.mean(valores_validos)
    desvio = np.std(valores_validos)

    if valor < 20 or valor > 250:
        return {
            "valor_informado": valor,
            "media_registrada": round(media, 2),
            "desvio_padrao": round(desvio, 2),
            "titulo": "Valor fora da faixa ❌",
            "avaliacao": "O valor informado está fora da faixa fisiológica plausível para cães e gatos (20 a 200 BPM)."
        }

    z = abs((valor - media) / desvio)
    prob = (1 - norm.cdf(z)) * 2 * 100

    if z < 1:
        classificacao = "Dentro do esperado"
        titulo = "Batimento esperado ✅"
        interpretacao = (
            f"O valor de {valor} BPM está dentro do comportamento normal observado nos últimos dias. "
            f"A chance de ocorrer é alta ({round(prob, 2)}%)."
        )
    elif z < 2:
        classificacao = "Ligeiramente incomum"
        titulo = "Batimento um pouco fora do comum ⚠️"
        interpretacao = (
            f"O valor de {valor} BPM é um pouco diferente da média recente. "
            f"A chance de ocorrer é de aproximadamente {round(prob, 2)}%. Não é necessário se preocupar, mas observe o comportamento do seu pet."
        )
    elif z < 3:
        classificacao = "Incomum"
        titulo = "Batimento incomum ❗"
        interpretacao = (
            f"O valor de {valor} BPM é estatisticamente incomum com base nos últimos dias. "
            f"A chance de isso ocorrer naturalmente é de apenas {round(prob, 2)}%. Isso pode indicar agitação, estresse, exaustão ou até uma condição fisiológica crítica, como frequência cardíaca muito alta ou muito baixa. Observe o comportamento do seu pet e, se os sinais persistirem, tente acalmá-lo e procure um veterinário o quanto antes."
        )
    else:
        classificacao = "Raro ou fora do padrão"
        titulo = "Batimento raro ou atípico 🚨"
        interpretacao = (
            f"O valor de {valor} BPM é muito raro com base nos dados recentes. "
            f"A chance de ocorrer é de apenas {round(prob, 2)}%. Isso pode indicar uma situação atípica, erro na medição ou necessidade de atenção veterinária se persistir."
        )

    return {
        "valor_informado": valor,
        "media_registrada": round(media, 2),
        "desvio_padrao": round(desvio, 2),
        "probabilidade_percentual": round(prob, 2),
        "classificacao": classificacao,
        "titulo": titulo,
        "interpretacao": interpretacao,
        "avaliacao": interpretacao
    }

def media_ultimos_5_dias_validos(dados: List[dict]) -> dict:
    df = pd.DataFrame(dados)

    if 'data' not in df.columns or 'frequenciaMedia' not in df.columns:
        print("Colunas esperadas não encontradas. Colunas disponíveis:", df.columns.tolist())
        return {}

    df['data'] = pd.to_datetime(df['data'], errors='coerce').dt.date
    df['frequenciaMedia'] = pd.to_numeric(df['frequenciaMedia'], errors='coerce')

    df = df.dropna(subset=['data', 'frequenciaMedia'])

    medias_por_dia = df.groupby('data')['frequenciaMedia'].mean().round(2)

    ultimos_5_dias = medias_por_dia.sort_index(ascending=False).head(5)

    return ultimos_5_dias.sort_index().to_dict()

def media_ultimas_5_horas_registradas(dados: List[dict]) -> dict:
    df = pd.DataFrame(dados)
    if df.empty:
        return {"media": None, "media_por_hora": {}, "mensagem": "Nenhum dado disponível."}

    # Conversão e limpeza
    df["data"] = pd.to_datetime(df["data"], errors="coerce")
    df = df.dropna(subset=["data", "frequenciaMedia"])
    df["frequenciaMedia"] = pd.to_numeric(df["frequenciaMedia"], errors="coerce")
    df = df.dropna(subset=["frequenciaMedia"])

    # Ordenar por data decrescente
    df = df.sort_values(by="data", ascending=False)

    # Arredondar para hora cheia com 'h'
    df["hora"] = df["data"].dt.floor("h")

    # Selecionar as últimas 5 horas únicas
    ultimas_5_horas = df["hora"].drop_duplicates().head(5)

    # Filtrar os dados dessas horas
    df_filtrado = df[df["hora"].isin(ultimas_5_horas)]

    if df_filtrado.empty:
        return {"media": None, "media_por_hora": {}, "mensagem": "Nenhum dado nas últimas 5 horas registradas."}

    # Calcular média por hora
    medias_por_hora = df_filtrado.groupby("hora")["frequenciaMedia"].mean().sort_index()
    medias_formatadas = {str(hora): round(media, 2) for hora, media in medias_por_hora.items()}

    # Corrigindo a média geral (média das médias por hora)
    media_geral = round(medias_por_hora.mean(), 2)

    return {
        "media": media_geral,
        "media_por_hora": medias_formatadas
    }



def executar_regressao(batimentos: List[dict], movimentos: List[dict]) -> Dict:
    df_bat = pd.DataFrame(batimentos)
    df_mov = pd.DataFrame(movimentos)

    df_bat['data'] = pd.to_datetime(df_bat['data'])
    df_mov['data'] = pd.to_datetime(df_mov['data'])

    df_bat_grouped = df_bat.groupby('data').agg({'frequenciaMedia': 'mean'}).reset_index()
    df_mov_grouped = df_mov.groupby('data').mean(numeric_only=True).reset_index()

    df = pd.merge(df_bat_grouped, df_mov_grouped, on='data', how='inner')
    df = df.dropna(subset=['frequenciaMedia'])

    acelerometros = ['acelerometroX', 'acelerometroY', 'acelerometroZ']
    X = df[acelerometros]
    y = df['frequenciaMedia']

    # Correlação de Pearson
    correlacoes = {col: round(pearsonr(X[col], y)[0], 3) for col in X.columns}

    # Padronização
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Treinamento
    modelo = LinearRegression()
    modelo.fit(X_scaled, y)

    coef_dict = dict(zip(acelerometros, modelo.coef_.round(3)))
    coef_geral = round(modelo.intercept_, 3)
    funcao_regressao = f"frequenciaMedia = {coef_geral} + " + " + ".join(
        [f"({coef:.3f} * {var})" for var, coef in coef_dict.items()]
    )

    media_movimentos_pad = X_scaled[-10:].mean(axis=0).reshape(1, -1)
    predicoes = [modelo.predict(media_movimentos_pad)[0] for _ in range(5)]
    segundos_futuros = [(df['data'].max() + timedelta(seconds=i+1)).isoformat() for i in range(5)]
    projecao = dict(zip(segundos_futuros, np.round(predicoes, 2)))

    # Exporta estatísticas da padronização para reuso na predição
    scaler_info = {
        "media": scaler.mean_.tolist(),
        "desvio": scaler.scale_.tolist(),
        "variaveis": acelerometros
    }

    return {
        "coeficiente_geral": coef_geral,
        "coeficientes": coef_dict,
        "correlacoes": correlacoes,
        "r2": round(modelo.score(X_scaled, y), 3),
        "media_erro_quadratico": round(mean_squared_error(y, modelo.predict(X_scaled)), 2),
        "projecao_5_segundos": projecao,
        "funcao_regressao": funcao_regressao,
        "padronizacao": scaler_info
    }


