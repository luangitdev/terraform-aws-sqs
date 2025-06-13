# Sistema de Mensageria com AWS SQS e Terraform

## Descrição

Este projeto demonstra a implementação de um sistema de mensageria utilizando o padrão de Produtor/Consumidor. A comunicação entre os componentes é realizada através de uma fila no Amazon Simple Queue Service (AWS SQS). A infraestrutura da fila SQS é provisionada utilizando Terraform, e os scripts do produtor e consumidor são desenvolvidos em Python com a biblioteca Boto3.

## Status do Projeto

Status: Exemplo Funcional / Estudo :heavy_check_mark:

## Tecnologias Utilizadas

*   Python 3.x
*   Boto3 (AWS SDK para Python)
*   AWS SQS (Simple Queue Service)
*   Terraform
*   Docker (para o consumidor)

## Funcionalidades

*   **Produtor (`src/produtor.py`):** Envia mensagens para uma fila SQS. Cada mensagem simula o cadastro de um novo usuário, contendo nome e email.
*   **Consumidor (`src/consumidor.py`):** Lê mensagens da fila SQS, simula o processamento dessas mensagens (como o envio de um email de boas-vindas) e, em seguida, remove a mensagem da fila para evitar reprocessamento.
*   **Infraestrutura como Código (`infra/`):** Scripts Terraform para criar e gerenciar a fila SQS na AWS.

## Estrutura do Projeto

```
.
├── .github/workflows/  # Workflows do GitHub Actions (CI/CD)
│   ├── app-pipeline.yml
│   └── infra-pipeline.yml
├── infra/                # Arquivos do Terraform para a infraestrutura
│   ├── main.tf           # Configuração do provider AWS
│   ├── sqs.queue.tf      # Definição da fila SQS
│   ├── variables.tf      # Variáveis do Terraform
│   └── outputs.tf        # Outputs do Terraform (ex: URL da fila)
├── src/                  # Código fonte da aplicação
│   ├── produtor.py       # Script do produtor de mensagens
│   ├── consumidor.py     # Script do consumidor de mensagens
│   └── requirements.txt  # Dependências Python
├── .gitignore            # Arquivos e pastas ignorados pelo Git
├── Dockerfile.consumer   # Dockerfile para criar a imagem do consumidor
└── README.md             # Este arquivo
```

## Pré-requisitos

*   Conta na AWS com permissões para criar recursos SQS e IAM (role para `assume_role`).
*   [AWS CLI](https://aws.amazon.com/cli/) configurado com credenciais.
*   Terraform (versão ~> 1.0)
*   [Python](https://www.python.org/downloads/) (versão 3.7 ou superior) instalado.
*   [Pip](https://pip.pypa.io/en/stable/installation/) (gerenciador de pacotes Python) instalado.
*   [Docker](https://www.docker.com/get-started) instalado (opcional, para rodar o consumidor em container).

## Como Configurar a Infraestrutura (Terraform)

1.  **Navegue até o diretório `infra`:**
    ```bash
    cd infra
    ```
2.  **Configure suas credenciais AWS:**
    Certifique-se de que sua AWS CLI está configurada (`aws configure`) ou que as variáveis de ambiente `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, e opcionalmente `AWS_SESSION_TOKEN`, estão definidas.
    O arquivo `main.tf` está configurado para usar `assume_role`. Verifique o ARN do Role em `infra/variables.tf` e garanta que você tem permissão para assumi-lo. Se estiver usando `assume_role`, suas credenciais configuradas localmente devem ter permissão para assumir o Role especificado em `infra/variables.tf`.

3.  **Inicialize o Terraform:**
    Este comando baixa os providers necessários.
    ```bash
    terraform init
    ```
4.  **Revise o plano de execução:**
    Este comando mostra quais recursos serão criados.
    ```bash
    terraform plan
    ```
5.  **Aplique a configuração:**
    Este comando provisiona a infraestrutura na AWS. Confirme a aplicação digitando `yes`.
    ```bash
    terraform apply
    ```
    Após a conclusão, o Terraform exibirá a URL da fila SQS criada na seção de `outputs`. Guarde esta URL, pois ela será necessária para os scripts Python.

## Como Executar a Aplicação

### Configurando a URL da Fila SQS

Antes de executar os scripts do produtor e consumidor, você precisa da URL da fila SQS.
1.  **Obtenha a URL da Fila:**
    *   Se você acabou de executar `terraform apply`, a URL estará no output (`sqs_queue_url`).
    *   Caso contrário, no diretório `infra/`, execute:
        ```bash
        terraform output sqs_queue_url
        ```
2.  **Atualize os scripts Python:**
    Abra os arquivos `src/produtor.py` e `src/consumidor.py` e substitua o valor da variável `queue_url` pela URL obtida no passo anterior. (Para um ambiente de produção, é recomendável gerenciar essa configuração através de variáveis de ambiente ou um sistema de gerenciamento de configurações, mas para este exemplo, a modificação direta é suficiente.)
    ```python
    # Exemplo em produtor.py e consumidor.py
    queue_url = 'SUA_URL_DA_FILA_AQUI'
    ```
    **Observação:** A região da AWS também está definida nos scripts (`region_name='us-west-2'`). Certifique-se de que esta é a mesma região onde a fila foi criada.

### Executando o Produtor

1.  **Navegue até o diretório `src`:**
    ```bash
    cd src
    ```
2.  **Instale as dependências (se ainda não o fez):**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Execute o script do produtor:**
    ```bash
    python produtor.py
    ```
    Você deverá ver uma mensagem de confirmação com o ID da mensagem enviada.

### Executando o Consumidor

#### Opção 1: Diretamente com Python

1.  **Navegue até o diretório `src` (se não estiver lá):**
    ```bash
    cd src
    ```
2.  **Instale as dependências (se ainda não o fez):**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Execute o script do consumidor:**
    ```bash
    python consumidor.py
    ```
    O consumidor ficará ativo, aguardando e processando mensagens da fila.

#### Opção 2: Usando Docker

1.  **Certifique-se de que a URL da fila em `src/consumidor.py` está correta.** A imagem Docker usará o código como está no repositório. Se precisar alterar a URL da fila, edite o arquivo ANTES de construir a imagem, ou monte o arquivo como um volume no container.
2.  **Navegue até a raiz do projeto.**
3.  **Construa a imagem Docker:**
    ```bash
    docker build -t sqs-consumidor -f Dockerfile.consumer .
    ```
4.  **Execute o container:**
    Lembre-se de configurar as variáveis de ambiente da AWS para que o Boto3 dentro do container possa autenticar.
    ```bash
    docker run -e AWS_ACCESS_KEY_ID="SEU_ACCESS_KEY" -e AWS_SECRET_ACCESS_KEY="SEU_SECRET_KEY" -e AWS_SESSION_TOKEN="SEU_SESSION_TOKEN" sqs-consumidor
    ```
    (Se não estiver usando credenciais temporárias, `AWS_SESSION_TOKEN` pode não ser necessário. Se estiver usando um perfil AWS, você pode mapear o diretório `~/.aws` para o container: `docker run -v ~/.aws:/root/.aws sqs-consumidor`)

    O consumidor dentro do container começará a processar as mensagens.
    **Nota sobre credenciais no Docker:** Para ambientes de produção em serviços como ECS ou EKS, o ideal é utilizar IAM Roles for Tasks/Pods. As variáveis de ambiente ou a montagem do diretório `~/.aws` são mais adequadas para desenvolvimento e testes locais.

## Como Contribuir

Contribuições são bem-vindas! Se você tiver sugestões para melhorar este projeto, sinta-se à vontade para seguir os passos abaixo:
1.  Faça um Fork do projeto.
2.  Crie uma Branch para sua Feature (`git checkout -b feature/MinhaFeature`).
3.  Faça o Commit de suas mudanças (`git commit -m 'Adicionando MinhaFeature'`).
4.  Faça o Push para a Branch (`git push origin feature/MinhaFeature`).
5.  Abra um Pull Request.

Alternativamente, você pode abrir uma Issue com a tag "sugestão" ou "melhoria".

## Licença

Distribuído sob a Licença MIT.
