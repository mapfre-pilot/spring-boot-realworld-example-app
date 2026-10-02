# README

Esta aplicación fue generada usando ArqRef (Reference Architecture MAPFRE), puedes encontrar documentación y ayuda en [https://www.marketplace.mapfre.com](https://www.marketplace.mapfre.com).

Esta es una aplicación «microservicio» destinada a formar parte de una arquitectura de microservicios, por favor, consulte la página [Haciendo microservicios con Reference Architecture][] de la documentación para más información.

## Requisitos

Para poder trabajar con este repositorio necesitas tener instalado lo siguiente:

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Acceso a [Azure Artifacts](https://dev.azure.com/devopsmapfre/devopsmapfre/_artifacts/feed/releases). Esto es necesario para poder generar el fichero `settings.xml` que se necesita para poder acceder a los dependencias de `Azure Artifacts`.

## Estructura del proyecto

La estructura básica del repositorio destinado a desarrollar una aplicación basada en contenedores es la siguiente:

```sh
.
├── .github
│   └── workflows
│       ├── merge-commit.yml
│       └── pull-request.yml
├── docker
│   ├── Dockerfile
├── sources
│   ├── apps
│   │   └── product
│   ├── config
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── .flake8.cfg
│   ├── .pre-commit-config.yaml
│   ├── manage.py
│   ├── poetry.lock
│   └── pyproject.toml
├── .gitignore
├── README.md
└── security-metadata.toml
```

A continuación se enumeran cada uno de los elementos de esta estructura:

- `.gitignore`: fichero con la configuración por defecto de carpetas y ficheros a ignorar por `git`.
- `.github/workflows`: carpeta con los ficheros de configuración de `Github Actions` para la ejecución de `CI/CD` en la plataforma de Github.

A continuación se explican los ficheros que se encuentran en la carpeta `.github/workflows`:

- `pull-request.yml`: workflow destinado a ejecutarse en cada pull request que se abra en el repositorio de código fuente desde ramas `feature` o `hotfix`.
- `merge-commit.yml`: workflow para realizar las tareas típicas de publicación de artefactos y despliegue en entornos de desarrollo.
- `README.md`: fichero con detalle de la arquitectura de aplicación de contenedores.
- `docker/Dockerfile`: fichero base para construir la imagen de la aplicación.
- `docker/docker-compose.yaml`: `docker compose` para desplegar la aplicación junto con las dependencias que necesite.
- `docker/dockerignore`: archivo para ignorar ficheros y directorios durante el proceso de construcción de la imagen, con el objetivo de evitar que estos se copien a la imagen del contenedor por error.
- `pyproject.toml`: fichero de configuración para del proyecto, donde se incluyen las dependencias para poetry (gestor de dependencias de python).
- `sources`: carpeta donde se aloja el código fuente de la aplicación. Por defecto se genera una aplicación django con la configuración indicada en el wizard de Marketplace durante el proceso de creación.

La estructura de la aplicación base, en caso de no requerir crear módulos adicionales,  sería la que se puede ver a continuación dentro de la carpeta `sources`:

```sh
.
└── sources
    ├── apps
    │   └── product
    │       ├── management
    │       │   └── commands
    │       ├── operators
    │       ├── schemas
    │       ├── serializers
    │       ├── services
    │       │   ├── connectors
    │       │   └── providers
    │       ├── tasks
    │       ├── tests
    │       ├── views
    │       ├── apps.py
    │       └── urls.py
    ├── config
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    └── manage.py
```

La aplicación ```producto``` está compuesta por las siguientes carpetas para estructurar el código:

- `serializer`: Clases que definen y validan los parámetros de entrada y salida de los servicios.
- `schemas`: Define las distintas respuestas y codigos de error que van a devolver los servicios openapi.
- `views`: Implementa las vistas que van asociadas a las urls para los disntintos servicios
- `services/connectors`: Implementa las clases y métodos para integrar servicios externos con los que la aplicación tendrá comunicación.
- `services/providers`: Implementa las clases y métodos para integrar servicios externos que serán consumidos por la aplicación.
- `operators`: Implementa las clases y métodos necesarios para la lógica de los servicios y la transformación de los datos.
- `managements/commands`: Incluye todos los procesos y comandos que requieren del contexto de la aplicación, como los consumidores de mensaje.
- `tasks`: Implementa las funciones para las tareas asíncronas
- `tests`: Implementa las clases de tests unitarios de los demás componentes de la aplicación.

## Desarrollo local

### Instalar y gestionar versiones de python con Pyenv

```sh
pyenv install 3.11.11
pyenv global 3.11.11
```

Puedes consultar todas las versiones de python instaladas y la activa con el comando:

```sh
pyenv versions

  system
  3.6.15
  3.8.15
  3.10.6
* 3.11.11 (set by /home/myuser/.pyenv/version)
```

[https://realpython.com/intro-to-pyenv/](https://realpython.com/intro-to-pyenv/)

### Iniciar poetry en entorno local

Para generar un entorno virtual de python con las dependencias:

```sh
cd sources
poetry install
```

### Configurar pre-commit

Primero tenemos que activar el virtualenv donde tenemos instalado el precommit. Para ello, poetry nos da el comando necesario a traves de este:

```sh
poetry env activate
```

Activamos el virtualenv y ahora, dentro del directorio del repositorio donde, vinculamos el hook a git mediante este comando:

```sh
pre-commit install -c sources/.pre-commit-config.yaml
```

Con esto, cada vez que hagamos un nuevo commit, el hook se disparará y resolverá todas las reglas definidas en el pre-commit, usando la instancia instalada dentro de nuestro virtualenv.

### Comandos de lanzamiento

#### Iniciar la aplicacion

Finalmente, iniciamos los servicios de API con el comando:

```sh
cd sources
poetry run ./manage.py runserver 0:8888
```

Para lanzar la aplicación junto con el servidor podemos ejecutar el siguiente comando con `gunicorn`:

```sh
gunicorn config.wsgi:application --workers 4 --threads 100 --max-requests 1000 --max-requests-jitter 15 -b 0.0.0.0:8888 --log-level 'INFO'
```

#### Iniciar Celery

En caso de necesitar un celery para llevar a cabo tareas asíncronas podemos desplegarlo localmente mediante el siguiente comando.
Estos parámetros son ejemplos, deben ajustarse a las necesidades de cada componente y las capacidades del mismo.

```sh
celery -A config.celery.celery_app worker -n worker-default@%h -Q default --concurrency=4 --max-memory-per-child 200000 --max-tasks-per-child 100 --heartbeat-interval 10 --loglevel=INFO
```
Además, en caso de necesitar tareas periódicas es necesario lanzar un celery beat:

```sh
celery -A config.celery.celery_beat_app beat --loglevel=INFO
```
Recomendamos fijar la ruta del fichero de schedule en una ubicación concreta.
Si no se realiza, el fichero se genera en la ruta desde la que se lanza el comando, lo que puede provocar problemas si se lanza desde rutas diferentes.

```sh
celery -A config.celery.celery_beat_app beat --schedule=/local/celerybeat-schedule --loglevel=INFO
```

#### Iniciar un comando de Django

Generalmente estos comandos se localizan en el directorio `sources/<apps>/<app_name>/management/commands`. Estos comandos tienen generalmente el el objetivo de implementar _consumers_ y _producers_ de Kafka.

```sh
python manage.py kafka_consumer_event
```

### Testing y cobertura

Para ejecutar los test del componente podemos hacer a través del pre-commit, que asegura que no subamos commits con una gran cantidad de lineas de código sin cobertura, o directamente a través de estos comandos:

```sh
cd sources
poetry run pytest
poetry run pytest --cov=app

coverage report -m
```

Los parámetros de configuración de los tests y la cobertura se encuentran en el fichero `pyproject.toml`.

## Soporte docker compose

Si queremos reconstruir la imagen, tenemos que ejecutar el siguiente comando. Pero antes, tendremos que hacer login sobre el acr de azure para acceder al repositorio de imagenes:

```sh
az login
az acr login -n acrmapfredevops

docker-compose -f docker/docker-compose.yml build
```

Para levantar el componente lanzamos este (si añadimos la opcion -d, se mantiene en segundo plano):

```sh
docker-compose -f docker/docker-compose.yml up -d
```

Y para entrar dentro del contenedor y poder ejecutar algún comando:

```sh
docker-compose -f docker/docker-compose.yml exec tva ash
```


### Configuración de lanzamiento

El comportamiento del contenedor puede configurarse en el _docker compose_ mediante el atributo `services.<service_name>.command`.

El funcionamiento por defecto esperado de los contenedores de Django es la ejecución del servidor WSGI basado en `gunicorn` como se muestra en el apartado de [Iniciar la aplicacion](#iniciar-la-aplicacion).

> [!IMPORTANT]
> También es posible levantar contenedores de docker exclusivos para celery, comandos, etc, indicando el comando especifico

### Comunicación entre contenedores

Para aquellos escenarios en los que tengamos que trabajar con varios microservicios, vamos a necesitar tener disponible una red de docker configurada en la que incluyamos todos estos componentes que nos sean de necesidad.

Adicionalmente, para la comunicación entre estos componentes, es de utilidad tener un contenedor de nginx que haga de proxy sobre estos componentes. Por ello, facilitamos y recomendamos el uso de este docker-compose:

```yaml
version: "3.6"

services:
  arch-ram-nginx-proxy:
    container_name: arch-ram-nginx-proxy
    image: jwilder/nginx-proxy
    ports:
        - "80:80"
    volumes:
        - /var/run/docker.sock:/tmp/docker.sock:ro
    environment:
        - proxy_connect_timeout=75s
        - proxy_read_timeout=300s
        - client_max_body_size=1g
        - location=/favicon.ico { log_not_found off; }
    networks:
        - arch-ram-network

networks:
  arch-ram-network:
    name: arch-docker-network
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.3.0/24

```

Si levantamos este componente y generamos esta red, podremos a continuación levantar otros componentes para que sean accesibles a traves de `component-name.localhost`. Para ello, en el componente tendremos que añadir esta configuración:

```yaml
version: "3.6"

services:
    component-name:
        environment:
            - VIRTUAL_HOST=component-name.localhost
            - VIRTUAL_PORT=8888
        networks:
            - arch-ram-network

networks:
  arch-ram-network:
    name: arch-ram-network
    external: true
```

Así, el componente será visible dentro de la red `arch-ram-network` como `component-name.localhost`. Tendremos que eliminar de los componentes aquellos mapeos que tengan contra el mismo puerto, ya que podemos tener conflicto con su uso, y delegar eso en nginx.

## Comandos AZ

- Login acr

```sh
az login
az acr login -n acrmapfredevops
```

- Listado de imagenes

```sh
az acr repository list --name acrmapfredevops --output table | grep django
```

- Tags de una imagen

```sh
az acr repository show-tags --repository mapfre/esp/appianesad/tva --name acrmapfredevops --output table
```

## Configuración proyectos en Plataforma Github

Los workflows de Github se encuentran en la carpeta `.github/workflows`. Para que se ejecuten correctamente, es necesario que se configuren los secretos requeridos que se encuentran definidos en la cabecera de cada uno de los ficheros. Sólo será necesario aquellos que tienen ámbito de repositorio. Los que se indica que tienen ámbito de organización, ya se encuentran dados de alta y disponibles para ser utilizados por los workflows.

## Descargar imágenes repositorio Azure Container Registry

Para descargar imágenes del repositorio de Azure Container Registry, es necesario autenticarse con el comando `az acr login -n acrmapfredevops`

## ¿Cómo debo nombrar mis propias imágenes de la organización?

Para el nombrado de las imágenes, es necesario seguir el procedimiento indicado por la plataforma de Devops y que se puede consultar [aquí](https://marketplace.mapfre.com/docs/default/mapfredocument/devopsplatformdoc/github-azure-container-registry/#using-azure-container-registry-on-github))

Imágenes creadas o producidas por la organización, así como aquellas descargadas y personalizadas para uso interno, deben llevar la siguiente nomenclatura:

```
mapfre/[entity]/[product]/[image_name]
```

## Configuración workflows Github

El repositorio actual hace uso de workflows reusables. Para poder consultar más detalle sobre qué parámetros de configuración se pueden inyectar en la invocación, se puede consultar el repositorio donde se encuentran los workflows reusables [aquí](https://github.com/mapfre-tech/arch-ram-reusable-workflows/tree/v1)
