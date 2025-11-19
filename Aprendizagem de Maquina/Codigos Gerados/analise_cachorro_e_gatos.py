
import sys
import unicodedata
import re

try:
    import pandas as pd
    import matplotlib.pyplot as plt
    import seaborn as sns
except Exception as e:
    print("Erro ao importar pacotes. Instale as dependências com:")
    print("  pip install pandas matplotlib seaborn")
    sys.exit(1)

# Função para normalizar nomes (remove acentos, espaços -> _ e lower)
def normalizar_texto(s):
    if s is None:
        return s
    s = str(s)
    s = s.strip().lower()
    s = unicodedata.normalize("NFKD", s)
    s = s.encode("ascii", "ignore").decode("utf-8")
    s = re.sub(r"\s+", "_", s)
    s = re.sub(r"[^\w_]", "", s)  # remove caracteres não alfanuméricos (exceto _)
    return s

# Lê o CSV (ajuste o separador se necessário)
arquivo = "06_tabela_cachorros_gatos.csv"
df = pd.read_csv(arquivo, sep=';')

# Normaliza os nomes das colunas do DataFrame
orig_cols = df.columns.tolist()
normalized_cols = [normalizar_texto(c) for c in orig_cols]
col_map = dict(zip(orig_cols, normalized_cols))
df.rename(columns=col_map, inplace=True)

print("\n📊 INÍCIO DA ANÁLISE DOS CÃES E GATOS")
print("-------------------------------------------")
print("Colunas detectadas (normalizadas):")
for c in df.columns:
    print(" -", c)
print("-------------------------------------------")

# Possíveis nomes para as colunas de interesse (já normalizados)
possiveis_tipo_animal = [
    "tipo_do_animal", "tipo_de_animal", "tipo_animal", "animal_tipo", "especie",
    "especie_animal", "animal"
]
possiveis_classe_doenca = [
    "classe_doenca", "classe_de_doenca", "tipo_de_doenca", "doenca", "classe"
]

# Função que retorna o nome real da coluna encontrada
def achar_coluna(candidatos):
    for c in candidatos:
        if c in df.columns:
            return c
    return None

col_tipo_animal = achar_coluna(possiveis_tipo_animal)
col_classe_doenca = achar_coluna(possiveis_classe_doenca)

# Se não encontrar as colunas essenciais, mostra mensagem e sai
if col_tipo_animal is None:
    print("\n❗ Coluna de tipo do animal não encontrada entre as opções:")
    print(possiveis_tipo_animal)
    print("Verifique os nomes das colunas acima e ajuste o CSV ou o script.")
    sys.exit(1)

if col_classe_doenca is None:
    print("\n❗ Coluna de classe de doença não encontrada entre as opções:")
    print(possiveis_classe_doenca)
    print("Verifique os nomes das colunas acima e ajuste o CSV ou o script.")
    sys.exit(1)

# ===== Estatísticas básicas =====
total_registros = len(df)
print(f"\nTotal de registros: {total_registros}")

# Garantir que os valores nas colunas chave estejam string/normalizados:
df[col_tipo_animal] = df[col_tipo_animal].astype(str).map(normalizar_texto)
df[col_classe_doenca] = df[col_classe_doenca].astype(str).map(normalizar_texto)

print(f"Animais únicos: {df[col_tipo_animal].nunique()}")
print(f"Classes de doença únicas: {df[col_classe_doenca].nunique()}")
print("-------------------------------------------")

# ===== Frequências =====
freq_animais = df[col_tipo_animal].value_counts()
print("\nFrequência dos tipos de animais:")
print(freq_animais.to_string())  # .to_string() preserva o formato vertical

freq_doencas = df[col_classe_doenca].value_counts()
print("\nFrequência das classes de doenças:")
print(freq_doencas.to_string())

# ===== Duplicados e nulos =====
num_duplicados = df.duplicated().sum()
print(f"\n🔁 Linhas duplicadas encontradas: {num_duplicados}")

nulos_por_col = df.isnull().sum()
nulos_por_col = nulos_por_col[nulos_por_col > 0].sort_values(ascending=False)
if not nulos_por_col.empty:
    print("\n⚠️ Valores nulos por coluna:")
    for col, cnt in nulos_por_col.items():
        print(f" - {col}: {cnt}")
else:
    print("\n✅ Nenhum valor nulo detectado nas colunas (0 contagens mostradas).")

# ===== Salvar uma versão sem duplicatas  =====
df_sem_duplicatas = df.drop_duplicates()
arquivo_sem_dup = "06_tabela_cachorros_gatos_sem_duplicatas.csv"
df_sem_duplicatas.to_csv(arquivo_sem_dup, sep=';', index=False)
print(f"\n📁 Arquivo sem duplicatas salvo como: {arquivo_sem_dup} (linhas: {len(df_sem_duplicatas)})")

# ===== Preparar gráficos =====
sns.set(style="whitegrid")
# Frequência animais - gráfico horizontal
plt.figure(figsize=(8,5))
freq_animais.plot(kind='barh', color='steelblue')
plt.title("Frequência dos Tipos de Animais (Cães e Gatos)")
plt.xlabel("Quantidade")
plt.ylabel("Tipo de Animal")
plt.tight_layout()
plt.savefig("grafico_frequencia_animais_caes_gatos.png", dpi=300)
plt.close()

# Frequência doenças - gráfico horizontal
plt.figure(figsize=(8,5))
freq_doencas.plot(kind='barh', color='coral')
plt.title("Frequência das Classes de Doenças (Cães e Gatos)")
plt.xlabel("Quantidade")
plt.ylabel("Classe de Doença")
plt.tight_layout()
plt.savefig("grafico_frequencia_doencas_caes_gatos.png", dpi=300)
plt.close()

# ===== Matriz de correlação (heatmap) =====
df_numerico = df.select_dtypes(include=['number'])
if not df_numerico.empty:
    corr = df_numerico.corr()
    plt.figure(figsize=(10, 6))
    sns.heatmap(corr, annot=True, fmt=".2f", cmap="coolwarm", cbar=True)
    plt.title("Mapa de Correlação (Atributos Numéricos) - Cães e Gatos")
    plt.tight_layout()
    plt.savefig("heatmap_correlacao_caes_gatos.png", dpi=300)
    plt.close()
else:
    print("\n⚠️ Nenhuma coluna numérica encontrada para gerar a matriz de correlação (heatmap).")

# ===== Pairplot (matriz scatter) - escolhe até 4 colunas numéricas para performance =====
if not df_numerico.empty:
    cols_pair = df_numerico.columns.tolist()[:4]
    try:
        sns.pairplot(df[cols_pair + [col_classe_doenca]].dropna(), hue=col_classe_doenca, diag_kind="hist", corner=True)
        plt.suptitle("Matriz de Dispersão (Pairplot) - Cães e Gatos", y=1.02)
        plt.tight_layout()
        plt.savefig("pairplot_caes_gatos.png", dpi=300)
        plt.close()
    except Exception as e:
        print("\n⚠️ Erro ao gerar pairplot (talvez poucas linhas após dropna). Mensagem:", e)

# ===== Scatter simples entre duas primeiras colunas numéricas (se existirem) =====
if len(df_numerico.columns) >= 2:
    colx, coly = df_numerico.columns[0], df_numerico.columns[1]
    plt.figure(figsize=(7,5))
    sns.scatterplot(data=df, x=colx, y=coly, hue=col_classe_doenca, legend="brief", alpha=0.8)
    plt.title(f"Dispersão entre {colx} e {coly}")
    plt.tight_layout()
    plt.savefig("scatterplot_exemplo_caes_gatos.png", dpi=300)
    plt.close()
else:
    print("\nℹ️ Não há colunas numéricas suficientes para gerar scatterplot de exemplo.")

# ===== Mapa de cores dos valores da correlação (scatter-size) - se houver correlação =====
if not df_numerico.empty:
    corr = df_numerico.corr()
    corr_melt = corr.reset_index().melt(id_vars='index')
    corr_melt.columns = ['var1', 'var2', 'corr']
    plt.figure(figsize=(8,6))
    sns.scatterplot(data=corr_melt, x='var1', y='var2', size=corr_melt['corr'].abs(), hue='corr', palette='coolwarm', sizes=(50,400), legend='brief')
    plt.xticks(rotation=45, ha='right')
    plt.title("Mapa de cores dos valores de correlação")
    plt.tight_layout()
    plt.savefig("mapa_cores_correlacao_caes_gatos.png", dpi=300)
    plt.close()

# ===== Final =====
print("\n📈 GRÁFICOS GERADOS COM SUCESSO (arquivos):")
print("- grafico_frequencia_animais_caes_gatos.png")
print("- grafico_frequencia_doencas_caes_gatos.png")
print("- heatmap_correlacao_caes_gatos.png (se houver colunas numéricas)")
print("- pairplot_caes_gatos.png (se gerado)")
print("- scatterplot_exemplo_caes_gatos.png (se gerado)")
print("- mapa_cores_correlacao_caes_gatos.png (se gerado)")
print("-------------------------------------------")
print("✅ Análise concluída com sucesso!")
