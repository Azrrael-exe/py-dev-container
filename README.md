# Entorno de Desarrollo Python con Docker y Poetry

Este proyecto configura un entorno de desarrollo Python usando Docker, docker-compose y Poetry para gestionar dependencias. La imagen Docker utiliza un enfoque multistage para mantener el tamaño de la imagen final lo más pequeño posible mientras conserva todas las dependencias instaladas.

## Requisitos Previos

- Docker
- Docker Compose
- Make (opcional, para usar los comandos simplificados)
- Git (opcional, para clonar el repositorio)

## Estructura de Archivos

```
proyecto/
│
├── Dockerfile             # Configuración multistage para la imagen Docker
├── Dockerfile.jupyter     # Configuración para el contenedor de Jupyter
├── docker-compose.yml     # Configuración de Docker Compose
├── Makefile               # Comandos simplificados para el manejo del entorno
├── pyproject.toml         # Configuración de Poetry y dependencias
├── poetry.lock            # Archivo de bloqueo de dependencias (se genera automáticamente)
└── app/                   # Directorio de la aplicación
    └── __main__.py        # Punto de entrada de la aplicación
```

## Instrucciones de Uso

### 1. Inicializar el Proyecto

Clona este repositorio o copia los archivos en tu directorio de proyecto.

### 2. Personalizar Dependencias

Edita el archivo `pyproject.toml` para agregar tus dependencias específicas:

```toml
[tool.poetry.dependencies]
python = "^3.11"
# Agrega tus dependencias aquí
fastapi = "^0.100.0"
sqlalchemy = "^2.0.0"
```

### 3. Iniciar los Contenedores

**Usando Make (recomendado):**
```bash
# Iniciar todos los contenedores
make up
```

**Usando Docker Compose directamente:**
```bash
# Construir e iniciar los contenedores en modo background
docker-compose up -d
```

### 4. Usar el Entorno de Desarrollo

Tienes dos opciones para trabajar con el proyecto:

#### Opción A: Terminal Interactiva

**Usando Make:**
```bash
make bash
```

**Usando Docker Compose:**
```bash
docker-compose exec app bash
```

Una vez dentro del contenedor, tendrás acceso a una shell interactiva donde podrás ejecutar comandos Python y manejar tu aplicación.

#### Opción B: Jupyter Lab

**Usando Make (abre automáticamente el navegador si es posible):**
```bash
make jupyter
```

**Manualmente:**
Abre tu navegador web y ve a:
```
http://localhost:8888
```

Esto abrirá Jupyter Lab donde podrás crear notebooks y acceder a todos los archivos del proyecto, con el directorio raíz configurado como base.

### 5. Ejecutar la Aplicación

#### Desde la Terminal:

Dentro del contenedor, puedes ejecutar la aplicación con:

```bash
python -m app
```

Puedes detener la ejecución con `Ctrl+C` y ejecutarla nuevamente cuando necesites probar cambios.

#### Desde Jupyter:

Crea un nuevo notebook y ejecuta:

```python
# Importar y ejecutar la aplicación
from app.__main__ import main
main()
```

### 6. Desarrollo

- **Cambios en el código**: Los cambios que realices en el código se reflejan automáticamente en el contenedor, ya que el directorio está montado como volumen. Solo necesitas ejecutar nuevamente la aplicación para ver los cambios.

- **Cambios en dependencias**: Si modificas el archivo `pyproject.toml` para agregar, eliminar o actualizar dependencias, necesitarás reconstruir la imagen:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 7. Detener el Contenedor

```bash
docker-compose down
```

## Comandos Make

El proyecto incluye un Makefile para simplificar las operaciones comunes:

```bash
# Ver todos los comandos disponibles con descripciones
make help

# Iniciar todos los contenedores
make up

# Conectarse a la terminal del contenedor de la aplicación
make bash

# Abrir Jupyter Lab en el navegador
make jupyter

# Ver los logs de los contenedores
make logs

# Ver el estado de los contenedores
make ps

# Reconstruir las imágenes (útil después de cambios importantes)
make rebuild

# Actualizar dependencias después de modificar pyproject.toml
make install-deps

# Detener todos los contenedores
make down

# Limpieza completa (elimina contenedores, imágenes y volúmenes)
make clean
```

## Personalización

### Cambiar la Versión de Python

Edita el Dockerfile y cambia la imagen base:

```dockerfile
FROM python:3.11-slim AS builder
```

a la versión que necesites, por ejemplo:

```dockerfile
FROM python:3.9-slim AS builder
```

No olvides también actualizar la etapa final y la ruta de las dependencias.

### Agregar Herramientas Adicionales

Puedes instalar herramientas adicionales en la etapa final del Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y \
    bash \
    vim \
    git \
    && rm -rf /var/lib/apt/lists/*
```

## Solución de Problemas

### Permisos de Archivos

Si encuentras problemas de permisos al crear archivos dentro del contenedor, puedes agregar un usuario no root en el Dockerfile:

```dockerfile
# En la etapa final
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

### Puerto en Uso

Si el puerto especificado en docker-compose.yml ya está en uso, cámbialo por uno disponible:

```yaml
ports:
  - "8001:8000"  # Mapea el puerto 8001 del host al 8000 del contenedor
```

## Licencia

[Tu licencia aquí]