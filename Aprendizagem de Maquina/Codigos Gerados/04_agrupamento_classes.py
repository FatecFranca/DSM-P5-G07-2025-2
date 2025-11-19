import pandas as pd
import unicodedata
import re

# Caminhos dos arquivos
input_file = "03_tabela_filtrada.xlsx"
output_file = "04_tabela_agrupada.xlsx"

# Ler o arquivo
df = pd.read_excel(input_file)

# Função para normalizar texto (sem acento, minúsculo e com _)


def normalizar_texto(texto):
    if pd.isna(texto):
        return None
    texto = str(texto).strip().lower()
    texto = unicodedata.normalize("NFKD", texto)
    texto = texto.encode("ascii", "ignore").decode("utf-8")
    texto = re.sub(r"\s+", "_", texto)
    return texto


# Normalizar a coluna original
df["tipo_de_doenca"] = df["tipo_de_doenca"].apply(normalizar_texto)

# Dicionário de agrupamento (já em formato normalizado)
agrupamento_doencas = {
    "cardiovascular_hematologica": ["cardiovascular", "sanguinea", "hematologica"],
    "neuro_musculoesqueletica": ["neurologica", "musculoesqueletica"],
    "urogenital": ["renal", "reprodutiva", "mamaria"],
    "respiratoria": ["respiratoria"],
    "endocrina": ["endocrina"],
    "cutanea": ["cutanea"],
    "gastrointestinal": ["gastrointestinal"],
    "ocular": ["ocular"],
    "sistemica": ["sistemica"]
}

# Função para aplicar o agrupamento


def agrupar_doenca(tipo):
    if pd.isna(tipo):
        return None
    for nova_classe, tipos in agrupamento_doencas.items():
        if tipo in tipos:
            return nova_classe
    return tipo  # mantém o tipo original se não houver correspondência


# Criar nova coluna agrupada
df["classe_doenca"] = df["tipo_de_doenca"].apply(agrupar_doenca)

# Salvar resultado
df.to_excel(output_file, index=False)

print("✅ Agrupamento concluído com sucesso!")
print(f"📁 Nova tabela salva em: {output_file}")
print("📊 Coluna adicionada: classe_doenca (normalizada e agrupada)")
