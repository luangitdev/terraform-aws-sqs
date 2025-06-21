import boto3
import json
import time
import os

# Usa variável de ambiente em vez de hardcode.
sqs = boto3.client('sqs', region_name=os.getenv('AWS_DEFAULT_REGION', 'us-west-2'))
queue_url = os.getenv('SQS_QUEUE_URL')

if not queue_url:
    raise ValueError("SQS_QUEUE_URL environment variable is required")

print("Consumidor iniciado. Aguardando mensagens...")

while True:
    try:
        response = sqs.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=10
        )

        if 'Messages' in response:
            message = response['Messages'][0]
            receipt_handle = message['ReceiptHandle']
            
            corpo_mensagem = json.loads(message['Body'])
            nome = corpo_mensagem.get('nome', 'Desconhecido')
            email = corpo_mensagem.get('email', 'email@desconhecido.com')
            
            print(f"Processando e-mail para: {nome} ({email})")
            time.sleep(2)
            print("E-mail 'enviado' com sucesso!")

            sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=receipt_handle
            )
            print("Mensagem deletada da fila.\n")
        else:
            print("Nenhuma mensagem na fila. Aguardando...")
            
    except Exception as e:
        print(f"Erro ao processar mensagem: {e}")
        time.sleep(5)