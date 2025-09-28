<p align="center">
  <img src="../docs/img/capa-java.svg" alt="Capa do Projeto" width="100%" />
</p>

# 🧠 API em Java — Coleira Inteligente

Esta é a API RESTful desenvolvida com **Java** e **Spring Boot**, responsável por receber os dados enviados pela coleira inteligente e realizar o cadastro de usuários e animais no banco de dados.

---

## ⚙️ Tecnologias Utilizadas

- **Java 21**
- **Spring Boot**
- **MongoDB** (Banco de dados NoSQL)
- **Swagger/OpenAPI** (Documentação)
- **Render** (Hospedagem da API)

---

## 📐 Arquitetura

A API foi desenvolvida seguindo o padrão **DDD (Domain-Driven Design)**, escolhido pela facilidade de organizar as regras de negócio e manter o código desacoplado e escalável.

A estrutura do projeto é composta por:

- **Entidades (Domain):** Representam os modelos principais do sistema.
- **DTOs (Data Transfer Objects):** Utilizados para garantir a segurança do sistema, evitando o acesso direto às entidades e controlando os dados expostos pela API.
- **Controllers:** Responsáveis por receber as requisições HTTP e direcioná-las para os serviços.
- **Services:** Contêm as regras de negócio e a lógica de processamento dos dados.
- **Repositories:** Camada responsável pela persistência e acesso ao banco de dados (MongoDB).

---

## 📡 Endpoints

A API está hospedada na plataforma Render e pode ser acessada através do link:

🔗 [https://dsm-p4-g07-2025-7.onrender.com](https://dsm-p4-g07-2025-7.onrender.com)

A documentação interativa da API, feita com Swagger (OpenAPI), está disponível em:

📘 [https://dsm-p4-g07-2025-7.onrender.com/swagger](https://dsm-p4-g07-2025-7.onrender.com/swagger)

---

## 🧩 Banco de Dados

Utilizamos o **MongoDB** como banco de dados pela sua alta disponibilidade, flexibilidade na estrutura de dados e facilidade de escalabilidade. Como se trata de um projeto com dados variáveis (ex.: batimentos cardíacos, localização, movimentação), um banco NoSQL foi a melhor escolha.

---

Se você quiser testar a API ou contribuir com o projeto, fique à vontade para clonar o repositório e entrar em contato conosco!
