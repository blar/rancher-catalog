version: "2"
services:
    postgres:
        image: postgres:9.6-alpine
        environment:
            POSTGRES_DB: ${SENTRY_DB_NAME}
            POSTGRES_USER: ${SENTRY_DB_USER}
            POSTGRES_PASSWORD: ${SENTRY_DB_PASS}
            PGDATA: /data/postgres/data
        volumes:
            - sentry-postgres:/data/postgres/data
    cron:
        image: sentry:9.1.2
        environment:
            SENTRY_EMAIL_HOST: ${SENTRY_EMAIL_HOST}
            SENTRY_EMAIL_PASSWORD: ${SENTRY_EMAIL_PASSWORD}
            SENTRY_EMAIL_PORT: ${SENTRY_EMAIL_PORT}
            SENTRY_EMAIL_USER: ${SENTRY_EMAIL_USER}
            SENTRY_SECRET_KEY: ${SENTRY_SECRET_KEY}
            SENTRY_SERVER_EMAIL: ${SENTRY_SERVER_EMAIL}
            SENTRY_POSTGRES_HOST: ${SENTRY_DB_HOST}
            SENTRY_DB_NAME: ${SENTRY_DB_NAME}
            SENTRY_DB_USER: ${SENTRY_DB_USER}
            SENTRY_DB_PASSWORD: ${SENTRY_DB_PASS}
        command:
            - run
            - cron
        links:
            - postgres:postgres
            - redis:redis
    redis:
        image: redis:3.2-alpine
    sentry:
        image: sentry:9.1.2
        {{- if .Values.SENTRY_PUBLIC_PORT}}
        ports:
            - ${SENTRY_PUBLIC_PORT}:9000/tcp
        {{- end}}
        environment:
            SENTRY_EMAIL_HOST: ${SENTRY_EMAIL_HOST}
            SENTRY_EMAIL_PASSWORD: ${SENTRY_EMAIL_PASSWORD}
            SENTRY_EMAIL_PORT: ${SENTRY_EMAIL_PORT}
            SENTRY_EMAIL_USER: ${SENTRY_EMAIL_USER}
            SENTRY_SECRET_KEY: ${SENTRY_SECRET_KEY}
            SENTRY_SERVER_EMAIL: ${SENTRY_SERVER_EMAIL}
            SENTRY_POSTGRES_HOST: ${SENTRY_DB_HOST}
            SENTRY_DB_NAME: ${SENTRY_DB_NAME}
            SENTRY_DB_USER: ${SENTRY_DB_USER}
            SENTRY_DB_PASSWORD: ${SENTRY_DB_PASS}
        labels:
            {{- if .Values.TRAEFIK_ENABLE }}
            traefik.enable: "true"
            traefik.port: "9000"
            traefik.frontend.rule: "${TRAEFIK_FRONTEND_RULE}"
            {{- end}}
        command:
            - /bin/bash
            - -c
            - sentry upgrade --noinput && sentry createuser --email ${SENTRY_INITIAL_USER_EMAIL} --password ${SENTRY_INITIAL_USER_PASSWORD} --superuser && /entrypoint.sh run web || /entrypoint.sh run web
        links:
            - postgres:postgres
            - redis:redis
    worker:
        image: sentry:9.1.2
        environment:
            SENTRY_EMAIL_HOST: ${SENTRY_EMAIL_HOST}
            SENTRY_EMAIL_PASSWORD: ${SENTRY_EMAIL_PASSWORD}
            SENTRY_EMAIL_PORT: ${SENTRY_EMAIL_PORT}
            SENTRY_EMAIL_USER: ${SENTRY_EMAIL_USER}
            SENTRY_SECRET_KEY: ${SENTRY_SECRET_KEY}
            SENTRY_SERVER_EMAIL: ${SENTRY_SERVER_EMAIL}
            SENTRY_POSTGRES_HOST: ${SENTRY_DB_HOST}
            SENTRY_DB_NAME: ${SENTRY_DB_NAME}
            SENTRY_DB_USER: ${SENTRY_DB_USER}
            SENTRY_DB_PASSWORD: ${SENTRY_DB_PASS}
        command:
            - run
            - worker
        links:
            - postgres:postgres
            - redis:redis

volumes:
    sentry-postgres:
        driver: ${SENTRY_STORAGE_DRIVER}
        driver_opts:
            {{ .Values.SENTRY_STORAGE_DRIVER_OPT }}
