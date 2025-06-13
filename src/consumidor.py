import boto3 # type: ignore
import json
import time

# Cria um cliente SQS
sqs = boto3.client('sqs', region_name='us-west-2') # Use a sua região

# URL da sua fila SQS
queue_url = 'https://sqs.us-west-2.amazonaws.com/135350631478/projeto-sqs'

print("Consumidor iniciado. Aguardando mensagens...")

while True:
    # Recebe mensagens da fila
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1, # Pega uma mensagem por vez
        WaitTimeSeconds=10 # Espera até 10s por uma mensagem (long polling)
    )

    if 'Messages' in response:
        # Pega a primeira mensagem da resposta
        message = response['Messages'][0]
        receipt_handle = message['ReceiptHandle'] # Identificador para apagar a mensagem
        
        # Converte o corpo da mensagem de string JSON para um dicionário Python
        corpo_mensagem = json.loads(message['Body'])
        nome = corpo_mensagem['nome']
        email = corpo_mensagem['email']
        
        print(f"Processando e-mail para: {nome} ({email})")
        # Aqui iria a lógica real de envio de e-mail
        time.sleep(2) # Simula o tempo de envio do e-mail
        print("E-mail 'enviado' com sucesso!")

        # Deleta a mensagem da fila para não ser processada novamente
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        print("Mensagem deletada da fila.\n")
    else:
        print("Nenhuma mensagem na fila. Aguardando...")