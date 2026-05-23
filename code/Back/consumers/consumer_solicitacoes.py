import json
import sys
from pathlib import Path

import pika


BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(BASE_DIR))

from messaging.rabbitmq import (  # noqa: E402
    RABBITMQ_QUEUE,
    criar_conexao,
)


def processar_evento(ch, method, properties, body):
    try:
        payload = json.loads(body.decode("utf-8"))
    except json.JSONDecodeError:
        print("[Consumidor] Mensagem inválida recebida:")
        print(body.decode("utf-8", errors="replace"))
        ch.basic_ack(delivery_tag=method.delivery_tag)
        return

    evento = payload.get("evento")
    solicitacao_id = payload.get("solicitacao_id")
    status = payload.get("status_atual", payload.get("status"))

    print("\n[Consumidor] Evento recebido")
    print(f"Evento: {evento}")
    print(f"Solicitação ID: {solicitacao_id}")
    print(f"Status: {status}")
    print("Payload completo:")
    print(json.dumps(payload, ensure_ascii=False, indent=2))

    ch.basic_ack(delivery_tag=method.delivery_tag)


def main():
    conexao = criar_conexao()
    canal = conexao.channel()
    canal.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
    canal.basic_qos(prefetch_count=1)
    canal.basic_consume(
        queue=RABBITMQ_QUEUE,
        on_message_callback=processar_evento,
    )

    print(f"[Consumidor] Aguardando eventos na fila '{RABBITMQ_QUEUE}'.")
    print("[Consumidor] Pressione CTRL+C para encerrar.")

    try:
        canal.start_consuming()
    except KeyboardInterrupt:
        print("\n[Consumidor] Encerrando consumidor.")
        canal.stop_consuming()
    finally:
        conexao.close()


if __name__ == "__main__":
    main()
