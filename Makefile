SHELL := /bin/bash
.PHONY: help


## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo "${YELLOW} make ${RESET} ${GREEN}<target> [options]${RESET}"
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
    	message = match(lastLine, /^## (.*)/); \
		if (message) { \
			command = substr($$1, 0, index($$1, ":")-1); \
			message = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW_S}%-$(TARGET_MAX_CHAR_NUM)s${RESET} %s\n", command, message; \
		} \
	} \
    { lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''

## test locally with coverage
test:
	${INFO} "Testing $(TAG_ARGS)..."
	source dev.env; coverage erase; coverage run src/cryptum/manage.py test $(TAG_ARGS); coverage report

## run local server
server:
	source dev.env; python src/cryptum/manage.py runserver

## make migrations and migrate
migrate:
	source dev.env; python src/cryptum/manage.py makemigrations; python src/cryptum/manage.py migrate

## create container for development
dev:
	docker-compose up --build --force-recreate --remove-orphans --detach

## remove container
tear-dev:
	docker-compose down -v

## remove pycache files
clean:
	find . -path "*/__pycache__/*.py" -not -name "__init__.py" -delete; find . -path "*/__pycache__/*.pyc"  -delete

## Run CI tests.
ci-test:
	docker-compose build
	# docker-compose run cryptum coverage erase
	docker-compose run cryptum coverage run --source='.' manage.py test
	# docker-compose run cryptum coverage report --rcfile=.coveragerc
	# docker-compose run cryptum coverage html --rcfile=.coveragerc

## Start the prod environment
prod:
	docker-compose -f docker-compose.prod.yml up --build --force-recreate --remove-orphans

## Deploy static files
staticfiles:
	docker-compose -f docker-compose.yml -f docker-compose.staticfiles.yml build

ifeq (test,$(firstword $(MAKECMDGOALS)))
  TAG_ARGS := $(word 2, $(MAKECMDGOALS))
  $(eval $(TAG_ARGS):;@:)
endif

# COLORS
GREEN  := `tput setaf 2`
YELLOW := `tput setaf 3`
WHITE  := `tput setaf 7`
YELLOW_S := $(shell tput -Txterm setaf 3)
NC := "\e[0m"
RESET  := $(shell tput -Txterm sgr0)

INFO := @bash -c 'printf $(YELLOW); echo "===> $$1"; printf $(NC)' SOME_VALUE
SUCCESS := @bash -c 'printf $(GREEN); echo "===> $$1"; printf $(NC)' SOME_VALUE