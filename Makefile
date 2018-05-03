# Rules for docker related tasks

PROJECT_PATH = $(shell pwd)
SUPERUSER = admin
VERSION = $(shell ${PROJECT_PATH}/get_version.sh)
REPOSITORY = dutradda/ll-employee-manager
BASE_REPOSITORY = dutradda/ll-employee-manager-base
INTEGRATION_REPOSITORY = dutradda/ll-employee-manager-integration
DOCKER_RUN = docker run -i -t -v $(PROJECT_PATH):/ll-employee-manager
FIX_COVERAGE = sed -i -r -e "s%/ll-employee-manager/%${PROJECT_PATH}/%g" .coverage
HAS_CHANGES = $(shell git diff | wc -l)
GET_SERVICE_URL = minikube service employee-manager --url

ifeq "${VERSION}" ""
    $(error "Please, update the VERSION file after changes in the code")
endif

.PHONY: all build-deploy dev-env integration update-migrations migrate

all: integration dev-server

build-base:
	docker build . \
	    -t $(BASE_REPOSITORY):$(VERSION) -t $(BASE_REPOSITORY):latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager-base/Dockerfile \
	    --force-rm=true

build-integration: build-base
	docker build . \
	    -t $(INTEGRATION_REPOSITORY):$(VERSION) -t $(INTEGRATION_REPOSITORY):latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager-integration/Dockerfile \
	    --force-rm=true

pull-integration:
	docker pull $(INTEGRATION_REPOSITORY):$(VERSION)

ifdef SKIP_BUILD
integration:
else
ifdef CI
integration: pull-integration
else
integration: build-integration
endif
endif
	$(DOCKER_RUN) $(INTEGRATION_REPOSITORY):$(VERSION) && $(FIX_COVERAGE)

release-base: build-base
	docker push $(BASE_REPOSITORY)

release-integration: release-base integration
	docker push $(INTEGRATION_REPOSITORY)

ifdef SKIP_BUILD
dev-server:
else
dev-server: build-integration
endif
	$(DOCKER_RUN) --entrypoint python -p 8000:8000 $(INTEGRATION_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py runserver 0:8000

dev-update-migrations: build-integration
	$(DOCKER_RUN) --entrypoint python $(INTEGRATION_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py makemigrations employee_manager

dev-migrate: dev-update-migrations
	$(DOCKER_RUN) --entrypoint python $(INTEGRATION_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py migrate

dev-superuser: build-integration
	$(DOCKER_RUN) --entrypoint python $(INTEGRATION_REPOSITORY):$(VERSION) /ll-employee-manager/manage.py createsuperuser --email $(SUPERUSER)@luizalabs.com --username $(SUPERUSER)

check-deploy:
    ifneq "${HAS_CHANGES}" "0"
		$(error "Deploy can't be done with changes in workspace")
    endif

build-nginx:
	docker build . \
	    -t $(REPOSITORY)-nginx:$(VERSION) -t $(REPOSITORY)-nginx:latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager-nginx/Dockerfile \
	    --force-rm=true

release-nginx: build-nginx
	docker push $(REPOSITORY)-nginx

build-deploy: check-deploy build-base
	rm -rf dist/ll-employee-manager && \
	mkdir -p dist/ll-employee-manager && \
	git archive HEAD | tar -x -C dist/ll-employee-manager && \
	docker build . \
	    -t $(REPOSITORY):$(VERSION) -t $(REPOSITORY):latest \
		-f ${PROJECT_PATH}/docker/ll-employee-manager/Dockerfile \
	    --force-rm=true

release-deploy: build-deploy
	docker push $(REPOSITORY)

release-all: release-base release-integration release-nginx release-deploy

delete-deploy:
	kubectl delete deploy employee-manager && \
	kubectl delete service employee-manager

create-deploy:
	kubectl create -f docker/deployment.yml && \
	kubectl expose deploy employee-manager --type=NodePort --port=80 --target-port=8080 && \
	$(GET_SERVICE_URL)

get-url:
	$(GET_SERVICE_URL)

update-deploy:
	kubectl set image deployment/employee-manager employee-manager=$(REPOSITORY):$(VERSION) employee-manager-nginx=$(REPOSITORY)-nginx:$(VERSION)
