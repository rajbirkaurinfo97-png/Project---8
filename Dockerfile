# Purpose: Configure base Python image, install dependencies, copy artifacts, and expose Streamlit port

# 1. Base Python image
FROM python:3.10-slim

# 2. Set working directory inside container
WORKDIR /app

# 3. Prevent Python from writing .pyc files and buffer outputs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 4. Install system dependencies required for building scientific libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 5. Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy application code and model artifacts into the container
COPY app.py .
COPY processed_jobs.pkl .
COPY job_embeddings.npy .
COPY classification_model.pkl .

# 7. Expose default Streamlit port
EXPOSE 8501

# 8. Set healthcheck to monitor container status
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# 9. Specify launch command
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
