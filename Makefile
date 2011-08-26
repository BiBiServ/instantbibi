###
#DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#Copyright 2011 BiBiServ Curator Team, http://bibiserv.cebitec.uni-bielefeld.de,
#All rights reserved.
#
#The contents of this file are subject to the terms of the Common
#Development and Distribution License("CDDL") (the "License"). You
#may not use this file except in compliance with the License. You can
#obtain a copy of the License at http://www.sun.com/cddl/cddl.html
#
#See the License for the specific language governing permissions and
#limitations under the License.  When distributing the software, include
#this License Header Notice in each file.  If applicable, add the following
#below the License Header, with the fields enclosed by brackets [] replaced
# by your own identifying information:
#
#"Portions Copyrighted 2011 BiBiServ Curator Team, http://bibiserv.cebitec.uni-bielefeld.de"
#
#Contributor(s):
#
#Author: Armin Toepfer, atoepfer(at)techfak.uni-bielefeld.de
##


TMPDIR=/tmp/${USER}
DOMAINDIR=${TMPDIR}


all: help

help:
	@echo "\ntargets:\n======="
	@echo "instant      : fetches bibimainapp, appserver_config, base & codegen"
	@echo "             : downloads, installs, configures and starts glassfish 3 + deploys bibimainapp\n"
	@echo "tool         : see guugle";
	@echo "guugle       : installs codegen, creates guugle tool and deploys it (single function tool)"
	@echo "dialign      : installs codegen, creates dialign tool and deploys it (multiple function tool)"
	@echo "restart      : stop glassfish instance, clean database, start glassfish"
	@echo "restart.wipe : kills current glassfish instance, deletes old, creates & starts new domain"
	@echo "deploy       : deploys bibimainapp, glassfish has to be running"
	@echo "start        : see restart"
	@echo "stop         : kill current glassfish instance, remove domain"
	@echo "this.update  : updates only instantbibi"
	@echo "update       : updates all projects including instantbibi"
	@echo "clean        : cleans all projects"
	@echo "ivy.cache    : caches ivy-rep to ~/ivy-rep"
	@echo "ivy.wipe     : deletes ~/ivy-rep"
	@echo "wipeall      : deletes really _EVERYTHING_"
	@echo "help         : this help"

instant: domain.wipe appserver.kill download install deploy

ivy.wipe:
		rm -rf ~/ivy-rep;

ivy.cache: ivy.wipe
		mkdir ~/ivy-rep; cd /tmp; wget -q -np -r http://bibiserv.techfak.uni-bielefeld.de/ivy-rep/; mv bibiserv.techfak.uni-bielefeld.de/ivy-rep/* ~/ivy-rep; rm -rf /tmp/bibiserv.techfak.uni-bielefeld.de;

install: bibiserv2.manager gf31.rmzip gf31.get gf31.unzip gf31.rmzip appserver.createconfigs  update appserver.run ln.log

download: codegen.get base.get appserver.get bibimainapp.get

download-bibimainapp: codegen.get base.get appserver.get

ln.log:
	@ln -s /${DOMAINDIR}/bibidomain/logs logs

start: restart

restart:
	@cd appserver_config; ant stop clean-db start

restart.wipe: stop appserver.run

stop : appserver.kill domain.wipe

test:
	@echo ${TMPDIR}
	@echo ${DOMAINDIR}

bibiserv2.manager:
	@echo "role=testadmin\npassword=simplepassword\nport=8080\nserver=localhost" > $(HOME)/.bibiserv2_manager

gf31.get:
	@echo "#GLASSFISH: Fishing"
	@sh .scripts/fetchGlassfish.sh

gf31.rmzip:
	@echo "#GLASSFISH: Removing zip"
	@rm -rf glassfish-3.1.zip

gf31.unzip:
	@echo "#GLASSFISH: Installing"
	@unzip glassfish-3.1.zip;mv glassfish3 bibigf31

appserver.get:
	@echo "#APPSERVER_CONFIG: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/appserver_config

appserver.createconfigs:
	@echo "#APPSERVER_CONFIG: Creating configs"
	@echo "catalina.home=`pwd`/bibigf31\ndomain.dir=${DOMAINDIR}\ndomain=bibidomain\nadmin.user=admin\nspool.dir=${TMPDIR}/spool\nexecutable.dir=/vol/biotools\nserver.portbase=8000\ndb.port=8027\nadmin.port=8048" > appserver_config/local.configuration
	@echo "AS_ADMIN_PASSWORD=admin\nAS_ADMIN_MASTERPASSWORD=changeit" > appserver_config/local.passwordfile

appserver.run:
	@echo "#GLASSFISH: Configuring and startup"
	@mkdir -p ${TMPDIR}
	@mkdir -p ${DOMAINDIR}
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
	@cd bibimainapp; ant clean dist

bibimainapp.run: bibimainapp.dist
	@echo "#BIBIMAINAPP: Deploying"
	@bibigf31/bin/asadmin --user admin --passwordfile appserver_config/local.passwordfile --port 8048 --host localhost deploy --force --contextroot "" bibimainapp/dist/bibimainapp.war

bibimainapp.clean:
	@echo "#BIBIMAINAPP: Cleaning"
	@cd bibimainapp; ant clean-all clean-cache -q

deploy: bibimainapp.run

tool: guugle

guugle: codegen.do guugle.do guugle.deploy

dialign: codegen.do dialign.do dialign.deploy

guugle.deploy:
	@echo "#TOOL: Deploying"
	@cd ${TMPDIR}/guugle_*; touch resources/downloads/guugle-1.1.src.tar.gz; ant deploy
	
dialign.deploy:
	@echo "#TOOL: Deploying"
	@cd ${TMPDIR}/dialign_*; touch resources/downloads/dialign-2.2.1-src.tar.gz; touch resources/downloads/dialign-2.2.1-solaris.x86.v10.tar.gz; touch resources/downloads/dialign-2.2.1-solaris.sparc.v8.tar.gz; touch resources/downloads/dialign-2.2.1-win32.tar.gz; touch resources/downloads/dialign-2.2.1-universal-osx.dmg.zip; ant deploy

codegen.get:
	@echo "#CODEGEN: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/codegen

codegen.do: codegen.clean
	@echo "#CODEGEN: Installation into local ivy repository"
	@cd codegen; ant dist publish -q

codegen.clean:
	@echo "#CODEGEN: Cleaning"
	@cd codegen; ant clean-all clean-cache -q

base.get:
	@echo "#BASE: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/base

guugle.do:
	@echo "#BASE: Generating guugle tool"
	@TMP_DIR=${TMPDIR};export TMP_DIR; rm -rf /${TMPDIR}/guugle*; cd base; ant clean-cache; rm -rf lib;ant -Dxml=../codegen/testdata/guugle.bs2 

dialign.do:
	@echo "#BASE: Generating dialign tool"
	@TMP_DIR=${TMPDIR};export TMP_DIR; rm -rf /${TMPDIR}/dialign*; cd base; ant clean-cache; rm -rf lib;ant -Dxml=../codegen/testdata/dialign.bs2

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
	@echo "#UPDATE: codegen"; cd codegen; hg pull -q; hg update -q;
base.update:
	@echo "#UPDATE: base";cd base; hg pull -u -q;

domain.wipe:
	@echo "#DOMAIN: Deleting";rm -rf ${DOMAINDIR}/bibidomain

clean: base.clean appserver.clean codegen.clean bibimainapp.clean

wipeall: domain.wipe appserver.kill
	@echo "#WIPE"
	@rm -rf glassfish* bibigf31 appserver_config bibimainapp base codegen logs
