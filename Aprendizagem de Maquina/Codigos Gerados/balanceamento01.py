import pandas as pd
from sklearn.utils import resample
import random

# Lê o CSV original
df = pd.read_csv("06_tabela_cachorros_gatos.csv", sep=";")

# Define a coluna de doenças
col_doenca = "classe_doenca"

# Mostra frequência original
print("📊 Frequência original das classes de doenças:")
print(df[col_doenca].value_counts())

# Calcula limite base (mantendo as classes maiores)
limite_base = 73  # gastrointestinais têm 73
faixa_min, faixa_max = 70, 85  # faixa natural para novas amostras

dfs_balanceados = []

for classe, grupo in df.groupby(col_doenca):
    tamanho = len(grupo)

    if tamanho < limite_base:
        # Define um novo tamanho aleatório dentro da faixa
        novo_tamanho = random.randint(faixa_min, faixa_max)
        grupo_aumentado = resample(
            grupo,
            replace=True,
            n_samples=novo_tamanho,
            random_state=random.randint(1, 9999)
        )
        dfs_balanceados.append(grupo_aumentado)
    else:
        # Mantém as classes grandes sem alteração
        dfs_balanceados.append(grupo)

# Junta os grupos balanceados
df_balanceado = pd.concat(dfs_balanceados)

# Mostra a nova frequência
print("\n📈 Frequência após balanceamento natural (valores variados):")
print(df_balanceado[col_doenca].value_counts())

# Salva o resultado
arquivo_saida = "06_tabela_cachorros_gatos_balanceado_variante.csv"
df_balanceado.to_csv(arquivo_saida, sep=";", index=False)
print(f"\n✅ Arquivo salvo como '{arquivo_saida}'")

