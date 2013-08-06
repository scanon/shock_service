TARGET ?= /kb/deployment
DEPLOY_RUNTIME = /kb/runtime
SERVICE = shock_service
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
TPAGE_ARGS = --define kb_top=$(TARGET)

include $(KB_TOP)/tools/Makefile.common

.PHONY : test

all: deploy

deploy: deploy-service

# deploy-all is depricted, consider removing it and using the deploy target
deploy-all: deploy-service 

deploy-service: initialize
	$(TPAGE) --define site_url=http://kbase.us/services/shock \
					  api_url=http://kbase.us/services/shock \ 
					  site_port=7043 \ 
					  api_port=7044 \ 
					  site_dir=/disk0/site \ 
					  data_dir=/disk0/data \ 
					  logs=$(SERVICE_DIR)/logs/shock \ 
					  mongo_host=mongodb.kbase.us \ 
					  mongo_db=ShockDB \
					shock.cfg.tt > shock.cfg
	sh install.sh $(SERVICE_DIR) $(TARGET) prod

deploy-service-test: initialize
	$(TPAGE) --define site_port=7077 \ 
					  api_port=7078 \ 
					  site_dir=/mnt/Shock/site \ 
					  data_dir=/mnt/Shock/data \ 
					  logs=/mnt/Shock/logs \ 
					  mongo_host=localhost \ 
					  mongo_db=ShockDBtest \
					shock.cfg.tt > shock.cfg
	sh install.sh $(SERVICE_DIR) $(TARGET) test

initialize:
	git submodule init
	git submodule update
	$(TPAGE) $(TPAGE_ARGS) init/shock.conf.tt > /etc/init/shock.conf

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

