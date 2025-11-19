import pandas as pd
import unicodedata
import re

# Caminhos dos arquivos
input_file = "02_tabela_expandida.xlsx"
output_file = "03_tabela_filtrada.xlsx"

# Ler o arquivo
df = pd.read_excel(input_file)

# Função para normalizar texto (igual ao padrão usado anteriormente)


def normalizar_texto(texto):
    if pd.isna(texto):
        return None
    texto = str(texto).strip().lower()
    texto = unicodedata.normalize("NFKD", texto)
    texto = texto.encode("ascii", "ignore").decode("utf-8")
    texto = re.sub(r"\s+", "_", texto)
    return texto


# Normalizar a coluna tipo_de_doenca (garante consistência)
df["tipo_de_doenca"] = df["tipo_de_doenca"].apply(normalizar_texto)

# Lista de doenças a serem removidas
doencas_excluir = [
    "endocrina",
    "mamaria",
    "ocular",
    "oral",
    "reprodutiva",
    "sistemica"
]

# Filtrar linhas que NÃO contenham essas doenças
df_filtrado = df[~df["tipo_de_doenca"].isin(doencas_excluir)]

# Salvar resultado em novo arquivo
df_filtrado.to_excel(output_file, index=False)

print("✅ Linhas indesejadas removidas com sucesso!")
print(f"📁 Nova tabela salva em: {output_file}")
print(f"🩺 Linhas removidas: {len(df) - len(df_filtrado)}")
print(f"📊 Linhas restantes: {len(df_filtrado)}")
