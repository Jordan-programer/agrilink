FROM python:3.11

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Train models during build to guarantee environment compatibility
RUN python training/train_model.py
RUN python demand/train_demand.py

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5000"]
