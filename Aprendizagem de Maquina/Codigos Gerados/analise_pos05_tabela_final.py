import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Caminho do arquivo final
arquivo = "05_tabela_final.csv"

# Ler os dados
df = pd.read_csv(arquivo, sep=';')

# -------------------------------
# 1️⃣ Frequência das classes de animais
# -------------------------------
frequencia_animais = df["tipo_do_animal"].value_counts()

plt.figure(figsize=(8, 6))
frequencia_animais.plot(kind="bar", color="#4CAF50")
plt.title("Frequência dos Tipos de Animal")
plt.xlabel("Tipo de Animal")
plt.ylabel("Quantidade")
plt.xticks(rotation=0)
plt.tight_layout()
plt.savefig("grafico_frequencia_animais.png", dpi=300)
plt.show()

# -------------------------------
# 2️⃣ Frequência das classes de doenças
# -------------------------------
frequencia_doencas = df["classe_doenca"].value_counts()

plt.figure(figsize=(10, 6))
frequencia_doencas.plot(kind="bar", color="#2196F3")
plt.title("Frequência das Classes de Doenças")
plt.xlabel("Classe de Doença")
plt.ylabel("Quantidade")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig("grafico_frequencia_doencas.png", dpi=300)
plt.show()

# -------------------------------
# 3️⃣ Verificação de dados duplicados e incorretos
# -------------------------------
duplicatas = df.duplicated().sum()
print(f"🔁 Linhas duplicadas encontradas: {duplicatas}")

# -------------------------------
# 4️⃣ Heatmap (Mapa de calor de correlação)
# -------------------------------
# Seleciona apenas colunas numéricas para calcular correlação
colunas_numericas = df.select_dtypes(include=["int64", "float64"])

if not colunas_numericas.empty:
    plt.figure(figsize=(10, 6))
    sns.heatmap(colunas_numericas.corr(), annot=True, cmap="Blues", fmt=".2f")
    plt.title("Mapa de Calor - Correlação entre Variáveis Numéricas")
    plt.tight_layout()
    plt.savefig("heatmap_correlacao.png", dpi=300)
    plt.show()
else:
    print("⚠️ Nenhuma coluna numérica encontrada para gerar o heatmap.")

# -------------------------------
# 5️⃣ Relatório resumido
# -------------------------------
print("\n📊 RESUMO DA ANÁLISE")
print("-----------------------------")
print(f"Animais únicos: {df['tipo_do_animal'].nunique()}")
print(f"Classes de doença únicas: {df['classe_doenca'].nunique()}")
print(f"Total de registros: {len(df)}")
print("-----------------------------")
print("Gráficos salvos:")
print("- grafico_frequencia_animais.png")
print("- grafico_frequencia_doencas.png")
print("- heatmap_correlacao.png")
