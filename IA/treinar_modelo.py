import pandas as pd
import numpy as np
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn_pandas import DataFrameMapper
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
from sklearn2pmml import sklearn2pmml, PMMLPipeline
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import messagebox

# ======== FUNÇÃO PRINCIPAL DE TREINAMENTO ========
def treinar_modelo():
    try:
        # Carregar o CSV
        df = pd.read_csv("05_tabela_final.csv", sep=';')

        # Remover espaços em branco das colunas
        df.columns = df.columns.str.strip()

        print("Colunas encontradas no CSV:")
        print(df.columns.tolist())

        if "classe_doenca" not in df.columns:
            raise ValueError(f"A coluna 'classe_doenca' não foi encontrada. Colunas disponíveis: {df.columns.tolist()}")

        # Separar atributos e classe
        X = df.drop(columns=["classe_doenca"])
        y = df["classe_doenca"]

        # Identificar colunas numéricas e categóricas
        colunas_numericas = X.select_dtypes(include=[np.number]).columns.tolist()
        colunas_categoricas = X.select_dtypes(exclude=[np.number]).columns.tolist()

        # Criar mapper
        mapper = DataFrameMapper(
            [(colunas_numericas, StandardScaler())] +
            [([col], OneHotEncoder(sparse=False)) for col in colunas_categoricas],
            df_out=True
        )

        # Pipeline PMML com SVM
        pipeline = PMMLPipeline([
            ("mapper", mapper),
            ("svm", SVC(kernel="rbf", C=1.0, gamma="scale"))
        ])

        # Ajustar n_splits para não exceder a menor classe
        menor_classe = y.value_counts().min()
        n_splits = min(5, menor_classe)  # 5 é um valor seguro
        cv = StratifiedKFold(n_splits=n_splits, shuffle=True, random_state=42)

        # Cross-validation
        scores = cross_val_score(pipeline, X, y, cv=cv, scoring="accuracy")

        # Treinar modelo final
        pipeline.fit(X, y)

        # Salvar modelo PMML
        sklearn2pmml(pipeline, "modelo_smo.pmml", with_repr=True)

        # Métricas
        y_pred = pipeline.predict(X)
        print("\n=== RELATÓRIO DE CLASSIFICAÇÃO ===")
        print(classification_report(y, y_pred))
        print(f"Acurácia média ({n_splits}-fold): {scores.mean():.4f}")
        print(f"Desvio padrão: {scores.std():.4f}")

        # Matriz de confusão
        cm = confusion_matrix(y, y_pred)
        disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=pipeline.classes_)
        disp.plot(cmap="Blues")
        plt.title("Matriz de Confusão (Treino Completo)")
        plt.show()

        messagebox.showinfo("Treinamento Concluído", f"Modelo gerado com sucesso!\nAcurácia média: {scores.mean():.4f}")

    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro: {e}")
        raise

# ======== INTERFACE TKINTER ========
janela = tk.Tk()
janela.title("Treinamento do Modelo SMO (SVM)")
janela.geometry("420x250")

titulo = tk.Label(janela, text="Treinador de Modelo SMO (SVM)", font=("Arial", 14, "bold"))
titulo.pack(pady=15)

descricao = tk.Label(
    janela,
    text="Esse script treina um modelo SVM com cross-validation\n"
         "usando o arquivo '05_tabela_final.csv' e gera 'modelo_smo.pmml'.",
    justify="center"
)
descricao.pack(pady=10)

botao_treinar = tk.Button(janela, text="Treinar Modelo", font=("Arial", 12), bg="#4CAF50", fg="white", command=treinar_modelo)
botao_treinar.pack(pady=20)

janela.mainloop()
