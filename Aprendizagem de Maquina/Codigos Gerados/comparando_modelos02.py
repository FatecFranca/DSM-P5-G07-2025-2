import pandas as pd
from pypmml import Model
from sklearn.metrics import accuracy_score
import sys
import numpy as np

# ===============================
# 🔹 1. ARQUIVO DE TESTE
# ===============================
try:
    teste = pd.read_csv('amostra_gatos_cachorros_20_linhas.csv', sep=';')
except FileNotFoundError:
    print("❌ ERRO: Arquivo 'amostra_gatos_cachorros_20_linhas.csv' não encontrado.")
    sys.exit()

coluna_classe = 'classe_doenca'
X_teste = teste.drop(columns=[coluna_classe])
y_teste = teste[coluna_classe]

# ===============================
# 🔹 2. LISTA DE MODELOS A COMPARAR
# ===============================
nomes_modelos = ['LR', 'LDA', 'KNN', 'CART', 'NB', 'SVM']
modelos_comparar = []
for nome in nomes_modelos:
    modelos_comparar.append((f'{nome} (Gato/Cachorro)', f'modelo_{nome}.pmml'))
for nome in nomes_modelos:
    modelos_comparar.append((f'{nome} (Todos Animais)', f'modelo_{nome}(todos_animais).pmml'))

print(f"Iniciando teste V4 (Final) com {len(modelos_comparar)} modelos PMML...")
print(f"Dataset de teste: 'amostra_gatos_cachorros_20_linhas.csv' ({len(X_teste)} linhas)\n")

# ===============================
# 🔹 3. TESTE DE CADA MODELO
# ===============================
resultados = []

for nome, arquivo in modelos_comparar:
    try:
        modelo = Model.load(arquivo)
        predicoes_df = modelo.predict(X_teste)

        y_pred = None

        # --- LÓGICA DE PREDIÇÃO V4 (FINAL) ---
        
        # 1. Tenta achar predição direta (ex: 'predicted_classe_doenca')
        col_pred_direta = [c for c in predicoes_df.columns if c.startswith('predicted_')]
        if len(col_pred_direta) == 1:
            y_pred = predicoes_df[col_pred_direta[0]]
            # print(f"  (Info {nome}: Formato 'predicted_')") # Debug

        # 2. Se não, tenta achar 'probability_' (ex: 'probability_nenhuma')
        if y_pred is None:
            col_prob_underscore = [c for c in predicoes_df.columns if c.startswith('probability_')]
            if len(col_prob_underscore) > 0:
                df_probs = predicoes_df[col_prob_underscore]
                pred_col_nomes = df_probs.idxmax(axis=1)
                y_pred = pred_col_nomes.str.replace('probability_', '', n=1)
                # print(f"  (Info {nome}: Formato 'probability_')") # Debug

        # 3. Se não, tenta achar 'probability()' (ex: 'probability(nenhuma)')
        if y_pred is None:
            col_prob_parens = [c for c in predicoes_df.columns if c.startswith('probability(') and c.endswith(')')]
            if len(col_prob_parens) > 0:
                df_probs = predicoes_df[col_prob_parens]
                pred_col_nomes = df_probs.idxmax(axis=1)
                # Extrai o nome da classe de dentro dos parênteses
                # ex: 'probability(nenhuma)' -> 'nenhuma'
                y_pred = pred_col_nomes.str.extract(r'probability\((.*?)\)')[0]
                # print(f"  (Info {nome}: Formato 'probability()')") # Debug

        # 4. Se falhar em todos, desiste
        if y_pred is None:
            colunas_reais = list(predicoes_df.columns)
            print(f"  ❌ {nome} - ERRO: Não foi possível identificar a predição. (Colunas: {colunas_reais})")
            continue
        
        # --- FIM DA LÓGICA V4 ---

        # Calcula a acurácia
        acc = accuracy_score(y_teste, y_pred)
        resultados.append((nome, acc))
        print(f"  ✅ {nome} - Acurácia: {acc:.2%}")
        
    except FileNotFoundError:
        print(f"  ❌ {nome} - ERRO: Arquivo PMML '{arquivo}' não encontrado.")
    except Exception as e:
        print(f"  ❌ {nome} - ERRO ao testar '{arquivo}': {e}") 

# ===============================
# 🔹 4. RESULTADOS FINAIS
# ===============================
if resultados:
    df_resultados = pd.DataFrame(resultados, columns=['Modelo', 'Acurácia'])
    df_resultados = df_resultados.sort_values(by='Acurácia', ascending=False)
    
    output_csv = 'comparativo_modelos_PMML_v4_FINAL.csv'
    df_resultados.to_csv(output_csv, index=False)

    print("\n" + "=" * 40)
    print("🏆 RANKING FINAL V4 - Teste com PMMLs")
    print("=" * 40)
    print(df_resultados.to_string(index=False))
    print(f"\n💾 Resultados salvos em '{output_csv}'")
else:
    print("\nNenhum modelo foi testado com sucesso.")