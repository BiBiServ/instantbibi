all: help

help:
	@echo "\ntargets:\n======="
	@echo "instant      :downloads, installs, configures and starts glassfish 3 + deploys bibimainapp"
	@echo "instant-dev  :extends instant by fetching base and codegen"
	@echo "deploy       :deploys bibimainapp, glassfish has to be running"
	@echo "start        :see restart"
	@echo "restart      :kills current glassfish instance, deletes old, creates & starts new domain"
	@echo "tool         :installs codegen, creates guugle tool and deploys it"
	@echo "update       :updates all projects including instantbibi"
	@echo "wipeall      :deletes really _EVERYTHING_"
	@echo "help         :this help"

instant: domain.clean appserver.kill install deploy

instant-dev: instant codegen.get base.get

install: bibiserv2.manager gf31.get gf31.unzip gf31.rmzip appserver.get appserver.install appserver.createconfigs appserver.run ln.log bibimainapp.get bibimainapp.resolve 

ln.log:
	ln -s /tmp/bibidomain/logs logs

start: restart

restart: domain.clean appserver.kill appserver.run

bibiserv2.manager:
	@echo "role=testadmin\npassword=simplepassword\nport=8080\nserver=localhost" > ~/.bibiserv2_manager

gf31.get:
	@wget http://download.java.net/glassfish/3.1/release/glassfish-3.1.zip

gf31.rmzip:
	@rm glassfish-3.1.zip

gf31.unzip:
	@unzip glassfish-3.1.zip;@mv glassfish3 bibigf31

appserver.get:
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/appserver_config > /dev/null

appserver.install:
	@cd appserver_config;hg update -C GF3 > /dev/null

appserver.createconfigs:
	@echo "catalina.home=`pwd`/bibigf31\ndomain.dir=/tmp\ndomain=bibidomain\nadmin.user=admin\nspool.dir=/tmp/spool\nexecutable.dir=/vol/biotools\nserver.portbase=8000\ndb.port=8027\nadmin.port=8048" > appserver_config/local.configuration
	@echo "AS_ADMIN_PASSWORD=admin\nAS_ADMIN_MASTERPASSWORD=changeit" > appserver_config/local.passwordfile

appserver.run:
	@cd appserver_config; @ant configure start > /dev/null

appserver.kill:
	@sh scripts/kill_bibiserv.sh > /dev/null

bibimainapp.get:
	hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/bibimainapp

bibimainapp.resolve:
	cd bibimainapp; ant resolve

bibimainapp.dist:
	cd bibimainapp; ant clean-all dist

bibimainapp.run: bibimainapp.dist
	bibigf31/bin/asadmin --user admin --passwordfile appserver_config/local.passwordfile --port 8048 --host localhost deploy --force --contextroot "" bibimainapp/dist/bibimainapp.war

deploy: bibimainapp.run


tool: codegen.do base.do guugle.deploy

guugle.deploy:
	sh scripts/deployGuugle.sh

codegen.get:
	hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/codegen

codegen.do:
	cd codegen; rm -rf dist; hg update -C JSF2; ant dist publish

base.get:
	hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/base

base.do:
	export TMP_DIR=/tmp; rm -rf /tmp/guugle*; cd base; ant clean-cache; rm -rf lib;ant -Dxml=../codegen/testdata/guugle.bs2 -Dwithout_ws=true -Dwithout_moby=true -Dwithout_vb=true;

update:
	hg pull; hg update; cd appserver_config; hg pull; hg update; cd ../bibimainapp; hg pull; hg update; cd ../codegen; hg pull; hg update -C JSF2; cd ../base; hg pull; hg update

domain.clean:
	rm -rf /tmp/bibidomain

wipeall: domain.clean appserver.kill
	rm -rf glassfish* bibigf31 appserver_config bibimainapp base codegen
