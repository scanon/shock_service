TOP_DIR = ../..
TARGET ?= /kb/deployment
DEPLOY_RUNTIME = /kb/runtime
SERVICE = shock_service
SERVICE_DIR = $(TARGET)/services/$(SERVICE)

GO_TMP_DIR = /tmp/go_build.tmp

PRODUCTION = 1

ifeq ($(PRODUCTION), 1)
	SHOCK_SITE = /disk0/site
	SHOCK_DATA = /disk0/data
	SHOCK_LOGS = $(SERVICE_DIR)/logs/shock

	TPAGE_ARGS = --define kb_top=$(TARGET) \
	--define site_url=http://kbase.us/services/shock \
	--define api_url=https://kbase.us/services/shock-api	\
	--define site_port=7043 \
	--define api_port=7044 \
	--define site_dir=$(SHOCK_SITE) \
	--define data_dir=$(SHOCK_DATA) \
	--define logs_dir=$(SHOCK_LOGS) \
	--define mongo_host=mongodb.kbase.us \
	--define mongo_db=ShockDB
else
	SHOCK_SITE = /mnt/Shock/site
	SHOCK_DATA = /mnt/Shock/data
	SHOCK_LOGS = /mnt/Shock/logs

	TPAGE_ARGS = --define kb_top=$(TARGET) \
	--define site_port=7077 \
	--define api_port=7078 \
	--define site_dir=$(SHOCK_SITE) \
	--define data_dir=$(SHOCK_DATA) \
	--define logs_dir=$(SHOCK_LOGS) \
	--define mongo_host=localhost \
	--define mongo_db=ShockDBtest
endif

include $(TOP_DIR)/tools/Makefile.common

.PHONY : test

all: initialize prepare build-shock

build-shock: $(BIN_DIR)/shock-server

$(BIN_DIR)/shock-server: Shock/shock-server/main.go
	rm -rf $(GO_TMP_DIR)
	mkdir $(GO_TMP_DIR)
	export GOPATH=$(GO_TMP_DIR); go get -v github.com/MG-RAST/Shock/...
	cp $(GO_TMP_DIR)/bin/shock-server $(BIN_DIR)/shock-server
	cp $(GO_TMP_DIR)/bin/shock-client $(BIN_DIR)/shock-client

deploy: deploy-libs deploy-client deploy-service

deploy-libs:
	rsync --exclude '*.bak' -arv lib/. $(TARGET)/lib/.

deploy-client: all
	cp $(BIN_DIR)/shock-client $(TARGET)/bin/shock-client

deploy-service: all
	cp $(BIN_DIR)/shock-server $(TARGET)/bin
	$(TPAGE) $(TPAGE_ARGS) shock.cfg.tt > shock.cfg

	mkdir -p $(SHOCK_SITE) $(SHOCK_DATA) $(SHOCK_LOGS) $(SHOCK_SITE)/assets/misc
	cp -v -r Shock/shock-server/site/* $(SHOCK_SITE)
	rm -f $(SHOCK_SITE)/assets/misc/README.md
	cp -v Shock/README.md $(SHOCK_SITE)/assets/misc/README.md

	mkdir -p $(SERVICE_DIR) $(SERVICE_DIR)/conf $(SERVICE_DIR)/logs/shock $(SERVICE_DIR)/data/temp
	cp -v shock.cfg $(SERVICE_DIR)/conf/shock.cfg
	cp service/start_service $(SERVICE_DIR)/
	chmod +x $(SERVICE_DIR)/start_service
	cp service/stop_service $(SERVICE_DIR)/
	chmod +x $(SERVICE_DIR)/stop_service

initialize:
	git submodule init
	git submodule update
	$(TPAGE) $(TPAGE_ARGS) init/shock.conf.tt > /etc/init/shock.conf

prepare: lib/Bio/KBase/Shock.pm

lib/Bio/KBase/Shock.pm:
	cd lib; ./prepare.sh

clean:
	rm -fr $(GO_TMP_DIR)
	rm -f $(BIN)/shock-client $(BIN)/shock-server
	cd lib; ./prepare.sh clean
	rm -rf

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

