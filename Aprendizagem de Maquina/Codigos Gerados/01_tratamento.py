import pandas as pd
import unicodedata
import re

# Caminhos dos arquivos
input_file = "00_tabela.xlsx"
output_file = "01_tabela_tratada.xlsx"

# Função para remover acentuação e caracteres especiais


def remover_acentos(texto):
    if isinstance(texto, str):
        texto_normalizado = unicodedata.normalize('NFKD', texto)
        texto_sem_acentos = ''.join(
            [c for c in texto_normalizado if not unicodedata.combining(c)])
        return texto_sem_acentos
    return texto

# Função para substituir "SIM"/"NÃO" por True/False


def substituir_sim_nao(valor):
    if isinstance(valor, str):
        valor_limpo = valor.strip().upper()
        if valor_limpo == "SIM":
            return 1
        elif valor_limpo in ["NAO", "NÃO"]:
            return 0
    return valor

# Função para padronizar gênero (Macho/Fêmea → M/F)


def padronizar_genero(valor):
    if isinstance(valor, str):
        valor_limpo = valor.strip().upper()
        if valor_limpo == "MACHO":
            return 1
        elif valor_limpo in ["FEMEA", "FÊMEA"]:
            return 0
    return valor

# Função para padronizar o campo Duração


def padronizar_duracao(valor):
    if isinstance(valor, str):
        texto = valor.strip().lower()
        numeros = re.findall(r'\d+', texto)
        if not numeros:
            return None
        numero = int(numeros[0])
        if "semana" in texto:
            return numero * 7
        else:
            return numero
    elif isinstance(valor, (int, float)):
        return int(valor)
    return None

# Função para formatar strings: minúsculas e com underscores


def formatar_string(valor):
    if isinstance(valor, str):
        valor = valor.strip().lower()
        valor = re.sub(r'\s+', '_', valor)
        return valor
    return valor


def remover_graus_celsiues(valor):
    if isinstance(valor, str):
        valor = valor.lower().replace('°c', '').replace('° c', '').replace('c', '').strip()
        valor = valor.replace(',', '.')
        try:
            return float(valor)
        except ValueError:
            return valor  # caso não seja um número válido
    return valor



# Ler arquivo Excel
df = pd.read_excel(input_file)

# Remover acentos das colunas
df.columns = [remover_acentos(col) for col in df.columns]

# Colocar colunas em minúsculas e substituir espaços por "_"
df.columns = [re.sub(r'\s+', '_', col.strip().lower()) for col in df.columns]

# Remover acentos de valores
for col in df.columns:
    df[col] = df[col].map(remover_acentos)

# Substituir "SIM"/"NÃO" por True/False
for col in df.columns:
    df[col] = df[col].map(substituir_sim_nao)

# Padronizar gênero (M/F)
colunas_genero = [col for col in df.columns if col.lower() in [
    "genero", "gênero"]]
for col in colunas_genero:
    df[col] = df[col].map(padronizar_genero)

# Padronizar duração (dias/semanas → número de dias)
colunas_duracao = [col for col in df.columns if col.lower() == "duracao"]
for col in colunas_duracao:
    df[col] = df[col].map(padronizar_duracao)

# Formatar todas as strings: minúsculas e "_" nos espaços
for col in df.columns:
    df[col] = df[col].map(formatar_string)


# Salvar resultado final
df.to_excel(output_file, index=False)

print(f"Arquivo tratado salvo em: {output_file}")
