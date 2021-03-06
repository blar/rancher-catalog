version: '2'

services:
    traefik:
        image: foobox/traefik:1.7.18
        ports:
            - "$TRAEFIK_HTTP_PORT:80"
            - "$TRAEFIK_HTTPS_PORT:443"
        labels:
            io.rancher.scheduler.global: "true"
            io.rancher.scheduler.affinity:host_label: traefik_lb=true
            io.rancher.scheduler.affinity:container_label_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.agent.role: environment
            io.rancher.container.create_agent: "true"
            {{- if ne .Values.TRAEFIK_API_RULE "" }}
            traefik.enable: "true"
            traefik.port: "8000"
            traefik.frontend.rule: $TRAEFIK_API_RULE
            {{- end}}
        environment:
            TRAEFIK_ACME_ENABLE: $TRAEFIK_ACME_ENABLE
            TRAEFIK_ACME_EMAIL: $TRAEFIK_ACME_EMAIL
            TRAEFIK_ACME_KEYTYPE: $TRAEFIK_ACME_KEYTYPE
            TRAEFIK_ADMIN_AUTH_USERS: $TRAEFIK_ADMIN_AUTH_USERS
            TRAEFIK_API_ENABLE: $TRAEFIK_API_ENABLE
            TRAEFIK_API_STATISTICS: $TRAEFIK_API_STATISTICS
            TRAEFIK_COMPRESSION: $TRAEFIK_COMPRESSION
            TRAEFIK_DASHBOARD_ENABLE: $TRAEFIK_DASHBOARD_ENABLE
            TRAEFIK_HTTPS_ENABLE: $TRAEFIK_HTTPS_ENABLE
            TRAEFIK_METRICS_ENABLE: $TRAEFIK_METRICS_ENABLE
            TRAEFIK_PING_ENABLE: "true"
            TRAEFIK_TLS_VERSION_MIN: $TRAEFIK_TLS_VERSION_MIN
            TRAEFIK_RANCHER_ENABLE: "true"
            TRAEFIK_RANCHER_MODE: $TRAEFIK_RANCHER_MODE
            TRAEFIK_READ_TIMEOUT: $TRAEFIK_READ_TIMEOUT
            TRAEFIK_WRITE_TIMEOUT: $TRAEFIK_WRITE_TIMEOUT
            TRAEFIK_TLS_CIPHER_SUITES_PROFILE: $TRAEFIK_TLS_CIPHER_SUITES_PROFILE
        volumes:
            - $TRAEFIK_ACME_VOLUME:/etc/traefik/acme

volumes:
    $TRAEFIK_ACME_VOLUME:
