from datetime import datetime
from sqlalchemy import Column, Date, DateTime, Float, Integer, String, Text

from database.database import Base


class Solicitacao(Base):
    __tablename__ = "solicitacoes"

    id = Column(Integer, primary_key=True, index=True)

    cliente_id = Column(Integer, nullable=False, index=True)
    prestador_id = Column(Integer, nullable=True, index=True)

    titulo = Column(String(120), nullable=False)
    descricao = Column(Text, nullable=False)
    tipo_servico = Column(String(80), nullable=False)

    orcamento = Column(Float, nullable=True)
    prazo = Column(Date, nullable=True)
    referencia = Column(String, nullable=True)

    status = Column(String(30), nullable=False, default="PENDENTE")

    criado_em = Column(DateTime, default=datetime.utcnow, nullable=False)
    atualizado_em = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )