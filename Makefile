all: 
	@echo "\ntargets:\n======="
	@echo "instant\t\tdownloads and installs glassfish 3, appserver_config and bibimainapp"
	@echo "restart\t\tkills current glassfish instance, deletes /tmp/bibidomain, creates\n\t\tnew domain and starts it"
	@echo "update\t\tupdates projects instantbibi, appserver_config and bibimainapp"
	@echo "clean\t\tdeletes everything including bibimainapp"
instant: domain.clean appserver.kill install

install: bibiserv2.manager gf31.get gf31.unzip gf31.rmzip appserver.get appserver.install appserver.createconfigs appserver.run bibimainapp.get bibimainapp.resolve

restart: domain.clean appserver.kill appserver.run

bibiserv2.manager:
	echo "role=testadmin\npassword=simplepassword\nport=8080\nserver=localhost" > ~/.bibiserv2_manager

gf31.get:
	wget http://download.java.net/glassfish/3.1/release/glassfish-3.1.zip

gf31.rmzip:
	rm glassfish-3.1.zip

gf31.unzip:
	unzip glassfish-3.1.zip;mv glassfish3 bibigf31

appserver.get:
	hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/appserver_config

appserver.install:
	cd appserver_config;hg update -C GF3;

appserver.createconfigs:
	echo "catalina.home=`pwd`/bibigf31\ndomain.dir=/tmp\ndomain=bibidomain\nadmin.user=admin\nspool.dir=/tmp/spool\nexecutable.dir=/vol/biotools\nserver.portbase=8000\ndb.port=8027\nadmin.port=8048" > appserver_config/local.configuration
	echo "AS_ADMIN_PASSWORD=admin\nAS_ADMIN_MASTERPASSWORD=changeit" > appserver_config/local.passwordfile

appserver.run:
	cd appserver_config; ant configure start

appserver.kill:
	sh scripts/kill_bibiserv.sh

bibimainapp.get:
	hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/bibimainapp

bibimainapp.resolve:
	cd bibimainapp; ant resolve

update:
	hg pull; hg update; cd appserver_config; hg pull; hg update; cd ../bibimainapp; hg pull; hg update

domain.clean:
	rm -rf /tmp/bibidomain

clean: domain.clean appserver.kill
	rm -rf glassfish* bibigf31 appserver_config bibimainapp
