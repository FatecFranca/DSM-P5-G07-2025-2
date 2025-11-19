import pandas as pd
import os

# ==============================
# CONFIGURAÇÕES GERAIS
# ==============================
input_file = "01_tabela_tratada.xlsx"
output_file = "02_tabela_expandida.xlsx"
output_contagem = "02_contagem_sintomas.xlsx"

# Sintomas que NÃO incluidos
# (nem serão agrupados, nem virarão colunas)
sintomas_excluir = [
    "temperatura_do_corpo",
    "bolas_de_pelo",
    "diminuicao_da_producao_de_leite",
    "esconder-se",
    "pisar_no_chao",
    "arrepios",

]

# ==============================
# LIMPAR SAÍDAS ANTIGAS (opcional)
# ==============================
for arquivo in [output_file, output_contagem]:
    if os.path.exists(arquivo):
        os.remove(arquivo)
        print(f"Arquivo antigo removido: {arquivo}")

# ==============================
# LER TABELA ORIGINAL
# ==============================
df = pd.read_excel(input_file)

# Identificar colunas de sintomas
colunas_sintomas = [col for col in df.columns if col.startswith("sintoma_")]
if not colunas_sintomas:
    raise ValueError("Nenhuma coluna de sintoma encontrada no arquivo!")

# Juntar todos os sintomas
todos_sintomas = pd.concat([df[col]
                           for col in colunas_sintomas], ignore_index=True)

# Remover nulos, vazios e não textuais
todos_sintomas = todos_sintomas.dropna()
todos_sintomas = todos_sintomas[todos_sintomas != ""]
todos_sintomas = todos_sintomas[todos_sintomas.apply(
    lambda x: isinstance(x, str))]

# Contar frequência de cada sintoma
contagem_sintomas = todos_sintomas.value_counts()

# Lista de sintomas únicos
sintomas_unicos = contagem_sintomas.index.tolist()

# ==============================
# AGRUPAMENTOS MANUAIS DE SINTOMAS
# ==============================
agrupamentos_sintomas = {
    "agitacao": ["agitacao", "agitacao_leve", "agitacao_moderada", "frequencia_cardiaca_alta", "inquietacao", "inquietacao_leve", "inquietacao_noturna", "latidos_excessivos", "maior_reatividade", "movimentos_de_cabeca", "relincho_frequent", "balancar_a_cabeca", "relincho_ocasional", "sacudir_a_cabeca", "alongamento", "tremores", "tremores_leves", "tremores_musculares", "vocalizacao_alta", "vocalizacao_aumentada", "vocalizacao_constante", "vocalizacao_suave", "convulsoes", "desconforto_leve", "hiperatividade", "nervosismo", "amassar_com_as_patas"],
    "dificuldade_para_locomover": ["dificuldade_para_locomover", "dificuldade_para_pular", "claudicacao", "claudicacao_leve", "perda_de_coordenacao", "reduced_mobility", "dificuldade_ao_levantar", "andar"],
    "letargia": ["letargia", "letargia_pos-sono", "mastigacao_lenta"],
    "secrecao_ocular": ["secrecao_ocular", "secrecao_ocular_clara", "lacrimejamento", "olhos_lacrimejantes", "olhos_vermelhos", "pupilhas_dilatadas"],
    "perda_de_pelos": ["perda_de_pelos", "pelo_aspero", "queda_de_pelos", "reduced_wool_growth", "reduced_wool_production"],
    "coceira": ["coceira", "coceira_no_nariz", "coceira_nos_olhos", "coceira_ocasional", "esfregar-se", "esfregar-se_em_objetos", "prurido"],
    "secrecao_nasal": ["secrecao_nasal", "secrecao_nasal_clara", "secrecao_nasal_leve"],
    "inchaco": ["inchaco", "inchaco_abdominal", "inchaco_na_pata", "inchaco_nas_articulacoes", "inchaco_no_abdomen", "edema_(inchaco)", "pernas_inchadas", "articulacoes", "ganho_de_peso_leve", "articulacoes_inchadas"],
    "perda_de_apetite": ["perda_de_apetite", "perda_de_apetitie", "dificuldade_para_comer", "mastigacao_lenta", "mastigacao_ruminante", "mau_halito"],
    "espirros": ["espirros", "espirros_frequentes", "espirros_ocasional"],
    "dor": ["dor", "dor_abdominal", "dor_ao_urinar", "dor_nas_articulacoes"],
    "desidratacao": ["desidratacao", "desidratacao_leve", "sede_excessiva", "aumento_da_sede", "desidatracao"],
    "espamos_musculares": ["espamos_musculares_leves", "espasmos_musculares_leves", "espamos_musculares", "espasmos_musculares_leves"],
    "febre": ["febre", "febre_alta"],
    "tosse": ["tosse", "tosse_seca", "tosse_forte", "tosse_ocasional"],
    "vomito": ["vomito", "vomitos", "enjoo"],
    "diarreia": ["diarreia", "diarreia_aguda"],
    "lambedura": ["lambedura_das_patas", "lambedura_excessiva"],
    "dificuldade_para_respirar": ["dificuldade_para_respirar", "ofegacao", "sons_respiratorios_anormais", "ofegacao_constante", "ofegacao_intensa", "ofegacao_leve", "ofegacao_ocasional", "respiracao_acelerada", "respiracao_pesada", "respiracao_profunda", "respiracao_rapida", "respiracao_ruidosa"],
    "ronco": ["ronco_alto", "ronco_forte", "ronco_leve", "ronronar_alto"],
    "problemas_na_pele": ["descamacao", "feridas_na_pele", "pele_seca", "problemas_na_pele", "sensibilidade_na_pele", "vermelhidao_na_pele"],
    "fraqueza": ["fraqueza", "intolerancia_ao_exercicio", "bocejos_frequentes"],
    "ranger_de_dentes": ["ranger_de_dentes", "ranger_de_dentes_leve", "gengivas_inflamadas", "gengivas_palidas"],
    "salivacao": ["salivacao_moderada", "salivacao_excessiva"],
    "suor_alterado": ["suor_excessivo", "suor_leve", "suor_minimo", "suor_ocasional"],
    "dificuldade_para_urinar": ["dificuldade_para_urinar", "sangue_na_urina", "urinar_frequente", "aumento_da_urina"]
}

# ==============================
# CRIAR MAPEAMENTO DE AGRUPAMENTO
# ==============================
mapeamento_sintomas = {}
for grupo, lista in agrupamentos_sintomas.items():
    for sintoma in lista:
        # só adiciona se não estiver na lista de exclusão
        if sintoma not in sintomas_excluir:
            mapeamento_sintomas[sintoma] = grupo

# Para sintomas não agrupados e não excluídos, mantém o nome original
for sintoma in sintomas_unicos:
    if sintoma not in mapeamento_sintomas and sintoma not in sintomas_excluir:
        mapeamento_sintomas[sintoma] = sintoma

# ==============================
# CRIAR AS NOVAS COLUNAS BOOLEANAS
# ==============================
for grupo in sorted(set(mapeamento_sintomas.values())):
    df[grupo] = 0

# Preencher com 1 onde o sintoma (ou grupo) ocorre
for i, row in df.iterrows():
    sintomas_linha = [str(x).strip()
                      for x in row[colunas_sintomas] if isinstance(x, str)]
    grupos_presentes = {mapeamento_sintomas[s]
                        for s in sintomas_linha if s in mapeamento_sintomas}
    for g in grupos_presentes:
        df.at[i, g] = 1

# ==============================
# CONTAGEM FINAL DE SINTOMAS
# ==============================
contagem_final = df[list(set(mapeamento_sintomas.values()))].sum(
).sort_values(ascending=False).reset_index()
contagem_final.columns = ["sintoma", "ocorrencias"]

# ==============================
# LIMPAR E SALVAR RESULTADOS
# ==============================
df = df.drop(columns=colunas_sintomas)
df.to_excel(output_file, index=False)
contagem_final.to_excel(output_contagem, index=False)

print(f"✅ Nova tabela expandida salva em: {output_file}")
print(f"✅ Tabela de contagem de sintomas salva em: {output_contagem}")
print(
    f"✅ Foram criadas {len(set(mapeamento_sintomas.values()))} colunas de sintomas (agrupadas e filtradas).")
