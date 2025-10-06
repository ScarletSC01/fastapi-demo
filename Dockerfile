# Usa la imagen oficial de Python como base
FROM python:3.11-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de requerimientos y código al contenedor
COPY requirements.txt .
COPY main.py .

# Instala dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Expone el puerto 8080 (Cloud Run lo usará a través de $PORT)
EXPOSE 8080

# Define la variable de entorno PORT para compatibilidad con Cloud Run
ENV PORT 8080

# Comando para ejecutar FastAPI usando uvicorn, respetando el puerto dinámico de Cloud Run
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]

