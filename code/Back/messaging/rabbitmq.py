import json
import os

import pika
from dotenv import load_dotenv


load_dotenv()

RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 5672))
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "forgedesk")
RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD", "forgedesk")
RABBITMQ_QUEUE = os.getenv("RABBITMQ_QUEUE", "forgedesk_eventos")


def criar_conexao():
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASSWORD)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        port=RABBITMQ_PORT,
        credentials=credentials,
        heartbeat=30,
        blocked_connection_timeout=5,
        connection_attempts=1,
        retry_delay=0,
    )
    return pika.BlockingConnection(parameters)


def publicar_evento(payload):
    try:
        conexao = criar_conexao()
        canal = conexao.channel()
        canal.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
        canal.basic_publish(
            exchange="",
            routing_key=RABBITMQ_QUEUE,
            body=json.dumps(payload, ensure_ascii=False),
            properties=pika.BasicProperties(
                content_type="application/json",
                delivery_mode=2,
            ),
        )
        conexao.close()
        return True
    except pika.exceptions.AMQPError as erro:
        print(f"[RabbitMQ] Falha ao publicar evento: {erro}")
        return False
    except OSError as erro:
        print(f"[RabbitMQ] Falha de conexão: {erro}")
        return False
