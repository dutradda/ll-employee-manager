# Rules for docker related tasks

PROJECT_PATH = $(shell pwd)
USER = admin
VERSION := $(shell ${PROJECT_PATH}/get_version.sh)
REPOSITORY := dutradda/ll-employee-manager
DEV_ENV_REPOSITORY := dutradda/ll-employee-manager-dev-env
DOCKER_RUN := docker run -p 8000:8000 -i -t -v $(PROJECT_PATH):/ll-employee-manager

ifeq "${VERSION}" ""
    $(error Please, update the VERSION file after changes in the code)
endif

.PHONY: all build-image dev-env integration update-migrations migrate

all: dev-env

build-image:
	docker build . \
	    -t $(REPOSITORY):$(VERSION) -t $(REPOSITORY):latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager/Dockerfile \
	    --force-rm=true

build-dev-env:
	docker build . \
	    -t $(DEV_ENV_REPOSITORY):$(VERSION) -t $(DEV_ENV_REPOSITORY):latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager-dev-env/Dockerfile \
	    --force-rm=true

dev-env: build-dev-env
	$(DOCKER_RUN) $(DEV_ENV_REPOSITORY):$(VERSION)

update-migrations:
	$(DOCKER_RUN)  --entrypoint python $(DEV_ENV_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py makemigrations employee_manager

migrate: update-migrations
	$(DOCKER_RUN)  --entrypoint python $(DEV_ENV_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py migrate

superuser:
	$(DOCKER_RUN)  --entrypoint python $(DEV_ENV_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py createsuperuser --email $(USER)@luizalabs.com --username $(USER)
