# Sistema de Mensageria Assíncrono com AWS SQS, Fargate e Terraform

![Status](https://img.shields.io/badge/status-funcional-green)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazon-aws&logoColor=white)

## Descrição

Este projeto demonstra a implementação de um sistema de mensageria resiliente e escalável utilizando o padrão de Produtor/Consumidor. A comunicação entre os componentes é realizada através de uma fila no **Amazon Simple Queue Service (SQS)**.

Toda a infraestrutura na AWS é provisionada de forma automatizada com **Terraform (IaC)**. A aplicação consumidora, desenvolvida em Python, é containerizada com **Docker** e executada de forma serverless no **AWS Fargate**. O ciclo de vida completo do projeto, da infraestrutura à aplicação, é automatizado com pipelines de **CI/CD no GitHub Actions**.

## Arquitetura do Projeto

O fluxo de trabalho é totalmente desacoplado:

1.  Um **Produtor** (simulado por um script Python) envia uma mensagem para a fila SQS.
2.  A **Fila SQS** armazena a mensagem de forma segura e durável.
3.  Um **Consumidor**, rodando como um serviço contínuo no **AWS Fargate**, "puxa" a mensagem da fila, a processa e a remove.
4.  Todo o deploy, tanto da infra quanto da aplicação, é automatizado via **GitHub Actions**.

## Tecnologias Utilizadas

* **AWS:** SQS, ECS, Fargate, ECR, IAM, VPC
* **IaC:** Terraform
* **Aplicação:** Python 3.x com Boto3
* **Containerização:** Docker
* **CI/CD:** GitHub Actions

## Estrutura de Pastas

```
.
├── .github/workflows/  # Workflows do GitHub Actions (CI/CD)
│   ├── app-pipeline.yml
│   └── infra-pipeline.yml
├── infra/                # Arquivos do Terraform para a infraestrutura
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── src/                  # Código fonte da aplicação
│   ├── consumidor.py
│   ├── produtor.py
│   └── requirements.txt
├── .gitignore
├── Dockerfile.consumer
└── README.md
```

## Configuração do Ambiente

Para rodar este projeto, uma configuração de permissões cuidadosa é necessária, seguindo o Princípio do Menor Privilégio.

### 1. Configuração de Permissões na AWS (Padrão `assume_role`)

Utilizamos um modelo com dois "atores" principais para segurança e flexibilidade: um Usuário IAM para a pipeline de CI/CD e uma Role para o Terraform executar as operações.

#### 1.1. O Usuário IAM para CI/CD (ex: `cicd-user`)

Este usuário é usado pelo GitHub Actions para se autenticar na AWS.

* **Criação:** Crie um usuário IAM no console da AWS.
* **Permissões Necessárias:**
    1.  **Permissão para assumir a role do Terraform:** Crie uma política inline que permita a ação `sts:AssumeRole` especificamente na role que será criada no próximo passo.
    2.  **Permissão para enviar imagens ao ECR:** Atache a política customizada `ECR-Push-Policy-ProjectSQS` que criamos anteriormente.

#### 1.2. A Role do Terraform (ex: `terraform-execution-role`)

Esta é a role que o Terraform "veste" para ter poder para criar a infraestrutura.

* **Criação:** Crie uma IAM Role.
* **Política de Confiança (Trust Policy):** Configure a role para que ela "confie" no usuário `cicd-user`, permitindo que ele a assuma.
* **Políticas de Permissão:** É **nesta role** que ficam as permissões para o trabalho de fato. Atache as políticas necessárias para gerenciar ECS, Fargate, SQS, IAM (para as roles de tarefa), VPC, etc.

### 2. Configuração dos Segredos no GitHub

No seu repositório GitHub, vá em `Settings > Secrets and variables > Actions` e crie os seguintes segredos:

* `AWS_ACCESS_KEY_ID`: A Access Key ID do seu `cicd-user`.
* `AWS_SECRET_ACCESS_KEY`: A Secret Access Key do seu `cicd-user`.
* `AWS_ACCOUNT_ID`: O ID de 12 dígitos da sua conta AWS.

### 3. Configuração Local (Opcional, para testes)

Para rodar o Terraform localmente, configure um perfil na sua máquina:
```bash
aws configure --profile cicd-user
```
E use as credenciais do seu `cicd-user`.

## Fluxo de Automação com CI/CD (GitHub Actions)

O projeto contém duas pipelines independentes:

* **`infra-pipeline.yml`**: Acionada por mudanças na pasta `infra/`. Ela executa `terraform init`, `plan` e `apply`, provisionando ou atualizando a infraestrutura na AWS.
* **`app-pipeline.yml`**: Acionada por mudanças na pasta `src/`. Ela constrói a imagem Docker do consumidor, a escaneia por vulnerabilidades, e a envia para o Amazon ECR. O passo final seria o deploy no ECS.

## Como Executar o Projeto

### 1. Provisionando a Infraestrutura

* **Automatizado (Recomendado):** Faça uma alteração em qualquer arquivo na pasta `infra/` e envie para a branch `main`. A pipeline `infra-pipeline.yml` será acionada e fará o `terraform apply` por você.
* **Manual (Para Testes Locais):**
    1.  Navegue até `infra/`.
    2.  Execute `terraform init`.
    3.  Para usar o `assume_role` localmente, seu `provider` precisa estar configurado para isso, e seu perfil local deve ter a permissão `sts:AssumeRole`.
    4.  Execute `terraform plan` e `terraform apply`.

### 2. Executando a Aplicação (Produtor e Consumidor)

O consumidor é projetado para rodar no Fargate. Para testar o produtor localmente e enviar mensagens para a fila na nuvem:

1.  **Obtenha a URL da Fila:** Após a execução da pipeline de infra, vá nos logs ou rode o comando localmente na pasta `infra/`:
    ```bash
    terraform output sqs_queue_url
    ```
2.  **Configure as Variáveis de Ambiente:** No seu terminal, configure as variáveis que os scripts Python precisam.
    ```bash
    # Autenticação (use o perfil configurado)
    export AWS_PROFILE=cicd-user

    # URL da fila obtida no passo anterior
    export SQS_QUEUE_URL="URL_DA_FILA_AQUI"
    ```
3.  **Execute o Produtor:**
    ```bash
    # Navegue para a pasta src
    cd ../src
    pip install -r requirements.txt
    python produtor.py
    ```
    Você verá uma confirmação de que a mensagem foi enviada. No console da AWS, você pode verificar que a mensagem chegou na fila SQS e que uma tarefa do Fargate a processou.

## Como Contribuir

Contribuições são bem-vindas! Sinta-se à vontade para abrir um Pull Request ou uma Issue.

## Licença

Distribuído sob a Licença MIT.
