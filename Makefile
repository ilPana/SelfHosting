# Function: Docker Rebuild
# [execute: down, remove, pull, build, up]
# $(call docker_rebuild,"stack_name")
define docker_rebuild
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml down && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml rm -f && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml pull && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml build --no-cache && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml up -d
endef
# Function: Docker Remove
# [execute: down, remove]
# $(call docker_remove,"stack_name")
define docker_remove
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml down && \
	docker compose -p $(1) -f docker/$(1)/docker-compose.yml rm -f
endef
# Initialization
init:
	docker network create --driver bridge reverse-proxy
# Remove Stack
remove:
	@if [ -z "$(stack)" ]; then echo "usage: make remove stack=portainer"; exit 1; fi
	$(call docker_remove,$(stack))
# Portainer
portainer:
	docker volume create portainer_data
	$(call docker_rebuild,"portainer")
# NGINX
nginx:
	docker volume create nginx_data
	docker volume create nginx_letsencrypt
	$(call docker_rebuild,"nginx")
#Headscale
headscale:
	$(call docker_rebuild,"headscale")
#Headscale-ui
headscale-ui:
	$(call docker_rebuild,"headscale-ui")
headscale-admin:
	$(call docker_rebuild,"headscale-admin")