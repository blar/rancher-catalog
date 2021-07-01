Labels for the service:

    traefik.enable=true
    traefik.http.services.$NAME.loadbalancer.server.port=80
    traefik.http.routers.$NAME.rule=Host("example.com")
