TARGET ?= /kb/deployment
DEPLOY_RUNTIME = /kb/runtime
SERVICE = shock_service
SERVICE_DIR = $(TARGET)/services/$(SERVICE)

.PHONY : test

all: deploy

deploy: deploy-service

# deploy-all is depricted, consider removing it and using the deploy target
deploy-all: deploy-service 

deploy-service:
	git submodule init
	git submodule update
	sh install.sh $(SERVICE_DIR) $(TARGET) prod

deploy-service-test:
	git submodule init
	git submodule update
	sh install.sh $(SERVICE_DIR) $(TARGET) test

# Test Section
TESTS = $(wildcard test/*.t)

test:
	# run each test
	for t in $(TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

