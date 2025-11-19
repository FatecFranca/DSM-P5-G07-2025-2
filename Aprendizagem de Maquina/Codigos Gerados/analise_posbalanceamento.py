import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ==============================
# 1️⃣ Leitura da tabela balanceada
# ==============================
arquivo = "06_tabela_cachorros_gatos_balanceado_variante.csv"  # nome do novo arquivo balanceado
df = pd.read_csv(arquivo, sep=';')

print("\n📊 INÍCIO DA ANÁLISE DO CONJUNTO BALANCEADO")
print("-------------------------------------------")

# Confirma colunas e frequência atualizada
print("Colunas detectadas:")
print(df.columns.tolist())

# ==============================
# 2️⃣ Frequência das classes de doenças
# ==============================
freq_doencas = df['classe_doenca'].value_counts()
print("\nFrequência das classes de doenças (Balanceada):")
print(freq_doencas)

plt.figure(figsize=(8,5))
sns.barplot(x=freq_doencas.values, y=freq_doencas.index, palette="coolwarm")
plt.title("Frequência das Classes de Doenças (Balanceadas)")
plt.xlabel("Quantidade")
plt.ylabel("Classe de Doença")
plt.tight_layout()
plt.savefig("grafico_frequencia_doencas_balanceada.png", dpi=300)
plt.close()

# ==============================
# 3️⃣ Matriz de dispersão (Pairplot)
# ==============================
# Filtra colunas numéricas
df_numerico = df.select_dtypes(include=['number'])

if not df_numerico.empty:
    # Escolhe até 4 colunas numéricas para visualização
    cols_pair = df_numerico.columns.tolist()[:4]

    sns.pairplot(df[cols_pair + ['classe_doenca']], hue='classe_doenca', diag_kind="hist", corner=True)
    plt.suptitle("Matriz de Dispersão (Base Balanceada)", y=1.02)
    plt.tight_layout()
    plt.savefig("pairplot_doencas_balanceada.png", dpi=300)
    plt.close()
    print("\n📈 Gráficos gerados com sucesso:")
    print("- grafico_frequencia_doencas_balanceada.png")
    print("- pairplot_doencas_balanceada.png")
else:
    print("\n⚠️ Nenhuma coluna numérica encontrada para gerar matriz de dispersão.")

print("-------------------------------------------")
print("✅ Análise da base balanceada concluída!")
