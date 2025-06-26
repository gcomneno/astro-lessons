# Makefile per gestire comandi Docker

# Variabili
WORKSPACE_DIR := /usr/src/astro-ws/
APP_NAME_DIR := my-wapp
DOCKER_IMAGE_NAME := astro_image

# Obiettivi
build:
	docker build -t $(DOCKER_IMAGE_NAME) .

run:
	docker run --rm -it -p 4321:4321 -v ./app:$(WORKSPACE_DIR)$(APP_NAME_DIR) $(DOCKER_IMAGE_NAME)
