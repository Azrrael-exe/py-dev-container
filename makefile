.PHONY: up down bash jupyter rebuild logs ps clean install-deps help

# Definir colores para la salida
YELLOW=\033[0;33m
GREEN=\033[0;32m
NC=\033[0m # No Color

# Detectar automáticamente el comando Docker Compose
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null || echo "docker compose")

# Mensaje de ayuda por defecto
help:
	@echo "${YELLOW}Comandos disponibles:${NC}"
	@echo "  ${GREEN}make up${NC}           : Iniciar todos los contenedores"
	@echo "  ${GREEN}make down${NC}         : Detener todos los contenedores"
	@echo "  ${GREEN}make bash${NC}         : Abrir una terminal bash en el contenedor app"
	@echo "  ${GREEN}make jupyter${NC}      : Mostrar la URL de Jupyter (y abrirla en navegadores compatibles)"
	@echo "  ${GREEN}make logs${NC}         : Ver los logs de todos los contenedores"
	@echo "  ${GREEN}make ps${NC}           : Ver el estado de los contenedores"
	@echo "  ${GREEN}make rebuild${NC}      : Reconstruir las imágenes y reiniciar los contenedores"
	@echo "  ${GREEN}make clean${NC}        : Eliminar contenedores, imágenes y volúmenes"
	@echo "  ${GREEN}make install-deps${NC} : Instalar nuevas dependencias después de modificar pyproject.toml"
	@echo "${YELLOW}Usando comando: ${NC}${GREEN}$(DOCKER_COMPOSE)${NC}"

# Iniciar todos los contenedores
up:
	@echo "${GREEN}Iniciando contenedores...${NC}"
	$(DOCKER_COMPOSE) up -d
	@echo "${GREEN}Contenedores iniciados. Jupyter disponible en http://localhost:8888${NC}"

# Detener todos los contenedores
down:
	@echo "${GREEN}Deteniendo contenedores...${NC}"
	$(DOCKER_COMPOSE) down

# Abrir una terminal bash en el contenedor app
bash:
	@echo "${GREEN}Conectando al contenedor app...${NC}"
	$(DOCKER_COMPOSE) exec app bash

# Mostrar la URL de Jupyter (y abrirla en navegadores compatibles)
jupyter:
	@echo "${GREEN}Jupyter Lab está disponible en:${NC}"
	@echo "http://localhost:8888"
	@# Intenta abrir el navegador (funciona en Linux, macOS y Windows con WSL)
	@(which xdg-open > /dev/null && xdg-open http://localhost:8888) || \
	 (which open > /dev/null && open http://localhost:8888) || \
	 (which cmd.exe > /dev/null && cmd.exe /c start http://localhost:8888) || \
	 echo "${YELLOW}Abre manualmente la URL en tu navegador${NC}"

# Ver los logs de todos los contenedores
logs:
	$(DOCKER_COMPOSE) logs -f

# Ver el estado de los contenedores
ps:
	$(DOCKER_COMPOSE) ps

# Reconstruir las imágenes y reiniciar los contenedores
rebuild:
	@echo "${GREEN}Reconstruyendo imágenes sin cache...${NC}"
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d
	@echo "${GREEN}Contenedores reconstruidos y reiniciados.${NC}"

# Eliminar contenedores, imágenes y volúmenes
clean:
	@echo "${YELLOW}Eliminando contenedores, imágenes y volúmenes...${NC}"
	$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans
	@echo "${GREEN}Limpieza completada.${NC}"

# Instalar nuevas dependencias después de modificar pyproject.toml
install-deps:
	@echo "${GREEN}Actualizando dependencias...${NC}"
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d
	@echo "${GREEN}Dependencias actualizadas.${NC}"