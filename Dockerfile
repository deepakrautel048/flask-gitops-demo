FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Install Nginx
RUN apt-get update && apt-get install -y nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Start Nginx and Gunicorn
CMD service nginx start && gunicorn --bind 0.0.0.0:8000 wsgi:app