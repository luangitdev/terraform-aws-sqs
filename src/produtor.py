import boto3 # type: ignore
import json

# Cria um cliente SQS
sqs = boto3.client('sqs', region_name='us-west-2') # Use a sua região

# URL da sua fila SQS (copie do console da AWS)
queue_url = 'https://sqs.us-west-2.amazonaws.com/135350631478/projeto-sqs'

# Mensagem a ser enviada (simulando um novo usuário)
novo_usuario = {
    'nome': 'Luan Castro',
    'email': 'luan.castro@exemplo.com'
}

print("Enviando pedido para a fila...")

# Envia a mensagem para a fila SQS
response = sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=json.dumps(novo_usuario) # O corpo da mensagem deve ser uma string
)

print(f"Mensagem enviada com sucesso! ID da Mensagem: {response['MessageId']}")