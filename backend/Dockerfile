FROM python:3.12-slim@sha256:87b49ee9d18db77b0afc7e3adbd994acb9544695217f6e8b4ff352a076a9e6a6

LABEL maintainer="Shurtugl"
LABEL description="projet demo sonarqube et autre devsec"
LABEL version=1.0

WORKDIR /app
COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py /app/

# Ajouter utilisateur non-root
RUN useradd -m appuser
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
