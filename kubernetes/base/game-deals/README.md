# Game Deals
- [Setup](#setup)

# Setup
1. Make a copy of [`conf/postgres.example.env`](./conf/postgres.example.env) named `postgres.env` and fill in you own values
2. Make a copy of [`conf/django.example.env`](./conf/django.example.env) named `django.env` and fill in your own values

# Todo
- Make the celery container get all the same env vars as the django
- Make django (and celery) use the SECRET_KEY env var from the secret
- Make the django (and celery) use any env vars in a non-secret
