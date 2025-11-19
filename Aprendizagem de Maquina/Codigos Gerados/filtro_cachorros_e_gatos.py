import pandas as pd

# Caminho do arquivo de entrada e saída
arquivo_entrada = "05_tabela_final.csv"
arquivo_saida = "06_tabela_cachorros_gatos.csv"

# Ler o arquivo CSV
df = pd.read_csv(arquivo_entrada, sep=';')

# Exibir os tipos de animal únicos (ajuda a confirmar o nome correto no filtro)
print("Tipos de animais encontrados:")
print(df["tipo_do_animal"].unique())

# Filtrar apenas registros de cães e gatos
df_filtrado = df[
    df["tipo_do_animal"].str.lower().isin(["cachorro", "gato"])
]

# Salvar o resultado em um novo arquivo CSV
df_filtrado.to_csv(arquivo_saida, sep=';', index=False)

# Exibir resumo do resultado
print("\n✅ Nova tabela gerada com sucesso!")
print(f"📁 Arquivo salvo como: {arquivo_saida}")
print(f"📊 Total de registros originais: {len(df)}")
print(f"📈 Registros após filtro (cães e gatos): {len(df_filtrado)}")
