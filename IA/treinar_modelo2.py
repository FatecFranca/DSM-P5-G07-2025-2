import pandas as pd
import numpy as np
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn2pmml import PMMLPipeline, sklearn2pmml
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import messagebox
import sklearn

# ======== FUNÇÃO PRINCIPAL DE TREINAMENTO ========
def treinar_modelo(model_type="svm"):
    try:
        # Carregar o CSV
        df = pd.read_csv("05_tabela_final.csv", sep=';')
        df.columns = df.columns.str.strip()  # remover espaços

        if "classe_doenca" not in df.columns:
            raise ValueError(f"A coluna 'classe_doenca' não foi encontrada. Colunas: {df.columns.tolist()}")

        # Separar atributos e classe
        X = df.drop(columns=["classe_doenca"])
        y = df["classe_doenca"]

        # Identificar colunas numéricas e categóricas
        colunas_numericas = X.select_dtypes(include=[np.number]).columns.tolist()
        colunas_categoricas = X.select_dtypes(exclude=[np.number]).columns.tolist()

        # Ajuste do OneHotEncoder para versões >= 1.2
        if int(sklearn.__version__.split('.')[1]) >= 2:
            encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
        else:
            encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')

        # ColumnTransformer
        preprocessor = ColumnTransformer([
            ("num", StandardScaler(), colunas_numericas),
            ("cat", encoder, colunas_categoricas)
        ])

        # Escolher modelo
        if model_type == "svm":
            modelo = SVC(kernel="rbf", C=1.0, gamma="scale", probability=True)
        elif model_type == "decision_tree":
            modelo = DecisionTreeClassifier(criterion="entropy", random_state=42)
        elif model_type == "random_forest":
            modelo = RandomForestClassifier(n_estimators=100, criterion="entropy", random_state=42)
        else:
            raise ValueError("Tipo de modelo inválido. Escolha 'svm', 'decision_tree' ou 'random_forest'.")

        # Pipeline PMML
        pipeline = PMMLPipeline([
            ("preprocessor", preprocessor),
            ("model", modelo)
        ])

        # Cross-validation
        menor_classe = y.value_counts().min()
        n_splits = min(5, menor_classe)
        cv = StratifiedKFold(n_splits=n_splits, shuffle=True, random_state=42)
        scores = cross_val_score(pipeline, X, y, cv=cv, scoring="accuracy")

        # Treinar modelo final
        pipeline.fit(X, y)

        # Salvar PMML
        sklearn2pmml(pipeline, f"modelo_{model_type}.pmml", with_repr=True)

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
        plt.title(f"Matriz de Confusão ({model_type})")
        plt.show()

        messagebox.showinfo("Treinamento Concluído", f"Modelo '{model_type}' gerado com sucesso!\nAcurácia média: {scores.mean():.4f}")

    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro: {e}")
        raise

# ======== INTERFACE TKINTER ========
janela = tk.Tk()
janela.title("Treinamento de Modelos")
janela.geometry("450x280")

titulo = tk.Label(janela, text="Treinador de Modelos", font=("Arial", 14, "bold"))
titulo.pack(pady=15)

descricao = tk.Label(
    janela,
    text="Treine modelos SVM, Decision Tree (J48) ou Random Forest\n"
         "usando o arquivo '05_tabela_final.csv'.",
    justify="center"
)
descricao.pack(pady=10)

botao_svm = tk.Button(janela, text="Treinar SVM", font=("Arial", 12), bg="#4CAF50", fg="white", command=lambda: treinar_modelo("svm"))
botao_svm.pack(pady=5)

botao_dt = tk.Button(janela, text="Treinar Decision Tree", font=("Arial", 12), bg="#2196F3", fg="white", command=lambda: treinar_modelo("decision_tree"))
botao_dt.pack(pady=5)

botao_rf = tk.Button(janela, text="Treinar Random Forest", font=("Arial", 12), bg="#FF9800", fg="white", command=lambda: treinar_modelo("random_forest"))
botao_rf.pack(pady=5)

janela.mainloop()
