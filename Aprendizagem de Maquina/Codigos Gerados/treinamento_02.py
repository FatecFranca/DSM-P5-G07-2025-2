# ================= IMPORTS =================
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, KFold, cross_val_score
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay, accuracy_score
from sklearn2pmml import PMMLPipeline, sklearn2pmml
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import messagebox
import sklearn

# ================= FUNÇÃO PRINCIPAL =================
def treinar_modelos(csv_file="06_tabela_todos_animais_balanceado_variante.csv"):
    try:
        # Carregar CSV
        df = pd.read_csv(csv_file, sep=';')
        df.columns = df.columns.str.strip()  # remover espaços

        # Separar atributos e classe
        target_col = "classe_doenca"
        if target_col not in df.columns:
            raise ValueError(f"A coluna '{target_col}' não foi encontrada. Colunas: {df.columns.tolist()}")
        X = df.drop(columns=[target_col])
        y = df[target_col]

        # Identificar colunas numéricas e categóricas
        colunas_numericas = X.select_dtypes(include=[np.number]).columns.tolist()
        colunas_categoricas = X.select_dtypes(exclude=[np.number]).columns.tolist()

        
        if int(sklearn.__version__.split('.')[1]) >= 2:
            encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
        else:
            encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')

        # Pré-processador
        preprocessor = ColumnTransformer([
            ("num", StandardScaler(), colunas_numericas),
            ("cat", encoder, colunas_categoricas)
        ])

        # Separar treino e validação
        validation_size = 0.20
        seed = 7
        X_train, X_val, y_train, y_val = train_test_split(
            X, y, test_size=validation_size, random_state=seed, stratify=y
        )

        # ================= MODELOS =================
        models = []
        models.append(('LR', LogisticRegression(solver='liblinear', multi_class='ovr')))
        models.append(('LDA', LinearDiscriminantAnalysis()))
        models.append(('KNN', KNeighborsClassifier()))
        models.append(('CART', DecisionTreeClassifier(criterion="entropy", random_state=seed)))
        models.append(('NB', GaussianNB()))
        models.append(('SVM', SVC(gamma='auto', probability=True)))

        # Avaliação por cross-validation no treino
        results = []
        names = []
        scoring = 'accuracy'
        print("\n=== AVALIAÇÃO COM CROSS-VALIDATION (TREINO) ===")
        for name, model in models:
            pipeline = PMMLPipeline([
                ("preprocessor", preprocessor),
                ("model", model)
            ])
            kfold = KFold(n_splits=10, shuffle=True, random_state=seed)
            cv_results = cross_val_score(pipeline, X_train, y_train, cv=kfold, scoring=scoring)
            results.append(cv_results)
            names.append(name)
            print(f"{name}: {cv_results.mean():.4f} ({cv_results.std():.4f})")

            # Treinar e gerar PMML
            pipeline.fit(X_train, y_train)
            pmml_filename = f"modelo_{name}(todos_animais).pmml"
            sklearn2pmml(pipeline, pmml_filename, with_repr=True)
            print(f"Modelo {name} salvo como {pmml_filename}")

        # Comparação dos algoritmos (boxplot)
        fig = plt.figure()
        fig.suptitle('Comparação de Algoritmos (Cross-Validation)')
        ax = fig.add_subplot(111)
        plt.boxplot(results)
        ax.set_xticklabels(names)
        plt.show()

        # Avaliação no conjunto de validação
        print("\n=== AVALIAÇÃO NO CONJUNTO DE VALIDAÇÃO ===")
        for name, model in models:
            pipeline = PMMLPipeline([
                ("preprocessor", preprocessor),
                ("model", model)
            ])
            pipeline.fit(X_train, y_train)
            y_pred = pipeline.predict(X_val)
            acc = accuracy_score(y_val, y_pred)
            print(f"\n{name} - Acurácia: {acc:.4f}")
            print("Classification Report:")
            print(classification_report(y_val, y_pred))
            cm = confusion_matrix(y_val, y_pred)
            disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=pipeline.classes_)
            disp.plot(cmap="Blues")
            plt.title(f"Matriz de Confusão ({name})")
            plt.show()

        messagebox.showinfo("Treinamento Concluído", "✅ Todos os modelos foram treinados e salvos como PMML (todos_animais)!")

    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro: {e}")
        raise

# ================= INTERFACE TKINTER =================
janela = tk.Tk()
janela.title("Treinamento de Modelos - Todos os Animais 🐾")
janela.geometry("520x360")

titulo = tk.Label(janela, text="Treinador de Modelos", font=("Arial", 14, "bold"))
titulo.pack(pady=15)

descricao = tk.Label(
    janela,
    text="Treine modelos LR, LDA, KNN, Decision Tree, Naive Bayes e SVM\n"
         "usando o arquivo '06_tabela_todos_animais_balanceado_variante.csv'.\n"
         "Cada modelo será salvo em formato PMML (todos_animais).",
    justify="center"
)
descricao.pack(pady=10)

botao_treinar = tk.Button(
    janela,
    text="Treinar Todos os Modelos",
    font=("Arial", 12),
    bg="#4CAF50",
    fg="white",
    command=lambda: treinar_modelos()
)
botao_treinar.pack(pady=20)

creditos = tk.Label(janela, text="PawsSafety | PetDex - v2.0", font=("Arial", 10, "italic"), fg="gray")
creditos.pack(side="bottom", pady=10)

janela.mainloop()
