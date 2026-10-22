FROM node:22-alpine AS frontend

WORKDIR /app/Frontend/nexofrontend
COPY Frontend/nexofrontend/package.json Frontend/nexofrontend/package-lock.json ./
RUN npm ci
COPY Frontend/nexofrontend/ ./
RUN npm run build

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY Backend/nexo_backend/ /app/Backend/nexo_backend/
COPY --from=frontend /app/Frontend/nexofrontend/dist/ /app/Frontend/nexofrontend/dist/

WORKDIR /app/Backend/nexo_backend
RUN pip install --no-cache-dir -r requirements.txt \
    && python manage.py collectstatic --noinput

EXPOSE 10000
CMD ["sh", "-c", "python manage.py migrate && python manage.py bootstrap_admin && exec gunicorn nexo_backend.wsgi:application --bind 0.0.0.0:${PORT:-10000}"]
