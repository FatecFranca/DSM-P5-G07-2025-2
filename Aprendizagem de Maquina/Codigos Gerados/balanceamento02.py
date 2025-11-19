import pandas as pd
from sklearn.utils import resample
import random

# === Lê o CSV original (com todos os animais) ===
df = pd.read_csv("05_tabela_final.csv", sep=";")

# Coluna de classes
col_doenca = "classe_doenca"

# Mostra a distribuição original
print("📊 Frequência original das classes de doenças:")
print(df[col_doenca].value_counts())

# Define o limite base e a faixa de oversampling
limite_base = df[col_doenca].value_counts().max()
faixa_min = int(limite_base * 0.9)
faixa_max = int(limite_base * 1.1)

dfs_balanceados = []

# Faz o oversampling aleatório
for classe, grupo in df.groupby(col_doenca):
    tamanho = len(grupo)

    if tamanho < limite_base:
        novo_tamanho = random.randint(faixa_min, faixa_max)
        grupo_aumentado = resample(
            grupo,
            replace=True,
            n_samples=novo_tamanho,
            random_state=random.randint(1, 9999)
        )
        dfs_balanceados.append(grupo_aumentado)
    else:
        dfs_balanceados.append(grupo)

# Junta os grupos balanceados
df_balanceado = pd.concat(dfs_balanceados)

# Mostra nova distribuição
print("\n📈 Frequência após balanceamento (valores variados):")
print(df_balanceado[col_doenca].value_counts())

# Salva o resultado
arquivo_saida = "06_tabela_todos_animais_balanceado_variante.csv"
df_balanceado.to_csv(arquivo_saida, sep=";", index=False)

print(f"\n✅ Arquivo salvo como '{arquivo_saida}'")
