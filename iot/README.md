<p align="center">
  <img src="../docs/img/capa-iot.svg" alt="Capa do Projeto" width="100%" />
</p>

# Projeto IoT — Coleira Inteligente para Monitoramento de Animais

Bem-vindo! Este é o nosso projeto de Internet das Coisas (IoT), desenvolvido com o objetivo de criar um dispositivo inteligente que possa ser acoplado a qualquer coleira de animal — especialmente cães 🐶 e gatos 😺 — para monitorar continuamente dados de saúde e localização do pet, de forma semelhante às smartbands e smartwatches ⌚ utilizados por humanos.

<p align="center">
  <img src="../docs/img/petdex-coleira-1.jpg" alt="Coleira PetDex" width="100%" />
</p>

<p align="center">
  <img src="../docs/img/petdex-coleira-2.jpg" alt="Coleira PetDex - 2" width="49%" />
  <img src="../docs/img/petdex-coleira-3.jpg" alt="Coleira PetDex - 3" width="49%" />
</p>

## 🚩 Problema Identificado

Atualmente, existe uma carência de soluções acessíveis e contínuas para monitoramento de saúde em animais domésticos, especialmente aqueles que possuem doenças crônicas ou estão em tratamento. Além disso, muitos tutores enfrentam dificuldades ao perder seus pets e não conseguirem localizá-los facilmente.

## 💡 Solução Proposta

Criamos uma coleira inteligente equipada com sensores capazes de coletar dados vitais e de movimentação do animal. Através desses dados, conseguimos monitorar:

- **Batimentos cardíacos**
- **Nível de atividade física**
- **Localização em tempo real**

Com isso, é possível detectar comportamentos anormais e enviar alertas ao tutor caso o batimento cardíaco do animal esteja fora da faixa considerada normal, especialmente em relação ao seu nível de movimentação.

Todos os dados coletados são enviados automaticamente para um banco de dados via uma API que desenvolvemos, permitindo o acompanhamento em tempo real.

## 📦 Componentes Utilizados

- **ESP32 S3 Zero**: Microcontrolador com conectividade Wi-Fi e Bluetooth, ideal pelo seu tamanho compacto.
- **GY-MAX30102**: Sensor de batimentos cardíacos e oxímetro.
- **MPU6050**: Sensor de giroscópio e acelerômetro, responsável por captar a movimentação do animal.
- **NEO-6M**: Módulo GPS para rastreamento em tempo real.
- **LED RGB**: Indicadores visuais de status da coleira.


<p align="center">
  <img src="./Conexoes IoT.jpg" alt="Conexões do IoT" width="100%" />
</p>


## 🔧 Funcionamento dos LED indicador

- **LED Azul**: Tentativa de conexão com a rede Wi-Fi.
- **LED Verde**: Dados coletados com sucesso e enviados ao banco de dados.
- **LED Vermelho**:
  - Se acender após o LED azul: falha na conexão com o sensor de batimentos cardíacos.
  - Se acender rapidamente depois: falha no envio dos dados ao servidor.
- **LED Branco**: Falha na obtenção da hora atual. Nesse caso, recomenda-se reiniciar a coleira.

## 🧩 Projeto 3D

Também desenvolvemos um **suporte 3D personalizado** para fixar o circuito à coleira do animal de forma segura, confortável e discreta. O suporte foi projetado levando em consideração o bem-estar do pet e a praticidade de uso.

---

## 🤖 Programação

A programação do dispositivo foi feita utilizando a **IDE do Arduino**, com foco na simplicidade e eficiência.

Todo o funcionamento está concentrado em um único arquivo principal, localizado na pasta [`/code`](./code), onde o usuário pode configurar previamente as redes Wi-Fi às quais a coleira deve tentar se conectar.

### Funcionamento Geral do Código

- Ao iniciar, a coleira tenta se conectar automaticamente a uma das redes Wi-Fi configuradas.
- Após o sucesso da conexão, o sistema realiza a leitura dos **batimentos cardíacos** do animal por cerca de **15 segundos**, calculando uma **média** dos valores coletados.
- Em seguida, os dados de:
  - **Batimentos cardíacos**
  - **Movimentação** (acelerômetro e giroscópio)
  - **Localização GPS**

  são enviados para o **endpoint da nossa API** por meio de uma requisição HTTP.

Essa estrutura permite que os dados sejam atualizados em tempo real no banco de dados, possibilitando o monitoramento remoto da saúde e localização do animal.
