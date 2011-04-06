all: help

help:
	@echo "\ntargets:\n======="
	@echo "instant      : fetches bibimainapp, appserver_config, base & codegen"
	@echo "             : downloads, installs, configures and starts glassfish 3 + deploys bibimainapp\n"
	@echo "tool         : installs codegen, creates guugle tool and deploys it"
	@echo "restart      : kills current glassfish instance, deletes old, creates & starts new domain"
	@echo "deploy       : deploys bibimainapp, glassfish has to be running"
	@echo "start        : see restart"
	@echo "this.update  : updates only instantbibi"
	@echo "update       : updates all projects including instantbibi"
	@echo "clean        : cleans all projects"
	@echo "wipeall      : deletes really _EVERYTHING_"
	@echo "help         : this help"

instant: domain.wipe appserver.kill install deploy

install: bibiserv2.manager codegen.get base.get gf31.rmzip gf31.get gf31.unzip gf31.rmzip appserver.get appserver.createconfigs bibimainapp.get update appserver.run ln.log

ln.log:
	@ln -s /tmp/bibidomain/logs logs

start: restart

restart: domain.wipe appserver.kill appserver.run

bibiserv2.manager:
	@echo "role=testadmin\npassword=simplepassword\nport=8080\nserver=localhost" > ~/.bibiserv2_manager

gf31.get:
	@echo "#GLASSFISH: Fishing"
	@sh .scripts/fetchGlassfish.sh

gf31.rmzip:
	@echo "#GLASSFISH: Removing zip"
	@rm glassfish-3.1.zip

gf31.unzip:
	@echo "#GLASSFISH: Installing"
	@unzip glassfish-3.1.zip;mv glassfish3 bibigf31

appserver.get:
	@echo "#APPSERVER_CONFIG: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/appserver_config

appserver.createconfigs:
	@echo "#APPSERVER_CONFIG: Creating configs"
	@echo "catalina.home=`pwd`/bibigf31\ndomain.dir=/tmp\ndomain=bibidomain\nadmin.user=admin\nspool.dir=/tmp/spool\nexecutable.dir=/vol/biotools\nserver.portbase=8000\ndb.port=8027\nadmin.port=8048" > appserver_config/local.configuration
	@echo "AS_ADMIN_PASSWORD=admin\nAS_ADMIN_MASTERPASSWORD=changeit" > appserver_config/local.passwordfile

appserver.run:
	@echo "#GLASSFISH: Configuring and startup"
	@cd appserver_config; ant configure start

appserver.kill:
	@echo "#GLASSFISH: Killing"
	@sh .scripts/kill_bibiserv.sh

appserver.clean:
	@echo "#APPSERVER_CONFIG: Cleaning"
	@cd base; rm -rf lib; ant clean-cache -q

bibimainapp.get:
	@echo "#BIBIMAINAPP: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/bibimainapp

bibimainapp.dist:
	@echo "#BIBIMAINAPP: Compiling"
	@cd bibimainapp; ant clean-all dist

bibimainapp.run: bibimainapp.dist
	@echo "#BIBIMAINAPP: Deploying"
	@bibigf31/bin/asadmin --user admin --passwordfile appserver_config/local.passwordfile --port 8048 --host localhost deploy --force --contextroot "" bibimainapp/dist/bibimainapp.war

bibimainapp.clean:
	@echo "#BIBIMAINAPP: Cleaning"
	@cd bibimainapp; ant clean-all clean-cache -q

deploy: bibimainapp.run


tool: codegen.do base.do guugle.deploy

guugle.deploy:
	@echo "#TOOL: Deploying"
	@sh .scripts/deployGuugle.sh 

codegen.get:
	@echo "#CODEGEN: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/codegen

codegen.do: codegen.clean codegen.update
	@echo "#CODEGEN: Installation into local ivy repository"
	@cd codegen; ant dist publish -q

codegen.clean:
	@echo "#CODEGEN: Cleaning"
	@cd codegen; ant clean-all clean-cache -q

base.get:
	@echo "#BASE: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/base

base.do:
	@echo "#BASE: Generating guugle tool"
	@export TMP_DIR=/tmp; rm -rf /tmp/guugle*; cd base; ant clean-cache; rm -rf lib;ant -Dxml=../codegen/testdata/guugle.bs2 -Dwithout_ws=true -Dwithout_moby=true -Dwithout_vb=true;

base.clean:
	@echo "#BASE: Cleaning"
	@cd base; ant clean-all clean-cache -q

update: this.update appserver.update bibimainapp.update codegen.update base.update

this.update:
	@echo "#UPDATE: instantbibi";hg pull -u -q; 
appserver.update:
	@echo "#UPDATE: appserver_config";cd appserver_config;hg update -C GF3 -q;
bibimainapp.update:
	@echo "#UPDATE: bibimainapp"; cd bibimainapp; hg pull -u -q;
codegen.update:
	@echo "#UPDATE: codegen"; cd codegen; hg pull -q; hg update -C JSF2 -q;
base.update:
	@echo "#UPDATE: base";cd base; hg pull -u -q;

domain.wipe:
	@echo "#DOMAIN: Deleting";rm -rf /tmp/bibidomain

clean: base.clean appserver.clean codegen.clean bibimainapp.clean

wipeall: domain.wipe appserver.kill
	@echo "#WIPE"
	@rm -rf glassfish* bibigf31 appserver_config bibimainapp base codegen logs
