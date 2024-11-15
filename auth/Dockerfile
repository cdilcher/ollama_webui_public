FROM python:3.12-alpine

RUN mkdir /app
COPY requirements.txt /app/requirements.txt
COPY main.py /app/main.py
RUN pip install -r /app/requirements.txt
WORKDIR /app
CMD ["uvicorn", "--host", "0.0.0.0", "--port", "8081", "main:app"]
EXPOSE 8081
