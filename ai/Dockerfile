FROM python:3.7

RUN pip install keras numpy tensorflow Pillow requests

WORKDIR /app
COPY . .

CMD [ "python", "main.py" ]