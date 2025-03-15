# Etapa de construcción para dependencias
FROM python:3.11-slim AS builder

# Evitar mensajes de Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Instalar Poetry
RUN pip install poetry==2.1.1

# Configurar Poetry para no crear un entorno virtual
RUN poetry config virtualenvs.create false

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Poetry
COPY pyproject.toml poetry.lock* ./

# Instalar dependencias
RUN poetry install --no-interaction --no-ansi --no-root

# -------------------------------------------
# Etapa de desarrollo (devcontainer)
# -------------------------------------------
FROM python:3.11-slim AS development

# Evitar mensajes de Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Instalar herramientas útiles para desarrollo
RUN apt-get update && apt-get install -y \
    bash \
    procps \
    curl \
    git \
    sudo \
    wget \
    make \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no root para devcontainer
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Crear el usuario
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Establecer directorio de trabajo
WORKDIR /app

# Dar propiedad del directorio de trabajo al usuario vscode
RUN chown -R $USERNAME:$USERNAME /app

# Copiar las dependencias instaladas desde la etapa de construcción
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copiar código de la aplicación
COPY . .

# Establecer usuario por defecto para desarrollo
USER $USERNAME

# Comando para ejecutar en modo desarrollo
CMD ["python", "-m", "app"]

# -------------------------------------------
# Etapa de producción
# -------------------------------------------
FROM python:3.11-slim AS production

# Evitar mensajes de Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Crear usuario para la aplicación
RUN useradd --create-home appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar solo las dependencias necesarias para producción
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copiar código de la aplicación
COPY . .

# Dar propiedad del directorio al usuario no-root
RUN chown -R appuser:appuser /app

# Cambiar al usuario no-root
USER appuser

# Comando para ejecutar en producción
CMD ["python", "-m", "app"]