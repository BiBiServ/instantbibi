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
#Contributor(s): Jan Krueger
#
#Authors: Armin Toepfer, atoepfer(at)techfak.uni-bielefeld.de
#         Jan Krueger, jkrueger(at)cebitec.uni-bielefeld.de
##


TMPDIR=/home/jan/tmp
DOMAINDIR=${TMPDIR}
ANTARGS=-lib `pwd`/.ant/lib


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
	@echo "stop         : kill current glassfish instance"
	@echo "stop.wipe    : kill current glassfish instance, remove domain"
	@echo "this.update  : updates only instantbibi"
	@echo "update       : updates all projects including instantbibi"
	@echo "clean        : cleans all projects"
	@echo "ivy.cache    : caches ivy-rep to ~/ivy-rep"
	@echo "ivy.wipe     : deletes ~/ivy-rep"
	@echo "wipeall      : deletes really _EVERYTHING_"
	@echo "help         : this help"
	@echo "inst.antopt  : install ant  optional libaries to local ant lib dir (${HOME}/.ant/lib)" 

instant: domain.wipe appserver.kill download install deploy

ivy.wipe:
		rm -rf ~/ivy-rep;

ivy.cache: ivy.wipe
		mkdir ~/ivy-rep; cd /tmp; wget -q -np -r http://bibiserv.techfak.uni-bielefeld.de/ivy-rep/; mv bibiserv.techfak.uni-bielefeld.de/ivy-rep/* ~/ivy-rep; rm -rf /tmp/bibiserv.techfak.uni-bielefeld.de;

install: bibiserv2.manager gf31.rmzip gf31.get gf31.unzip gf31.rmzip appserver.createconfigs  update appserver.run ln.log binaries.install

download: codegen.get base.get appserver.get bibimainapp.get resources.get

download-bibimainapp: codegen.get base.get appserver.get

ln.log:
	@ln -s /${DOMAINDIR}/bibidomain/logs logs

start: restart

restart:
	@cd appserver_config; ant ${ANTARGS} stop start

stop:appserver.kill

restart.wipee: stop appserver.run

stop.wipe : appserver.kill domain.wipe

test:
	@echo ${TMPDIR}
	@echo ${DOMAINDIR}
	@echo ${ANTARGS}

bibiserv2.manager:
	@echo "role=testadmin\npassword=simplepassword\nport=8080\nserver=localhost" > $(HOME)/.bibiserv2_manager

gf31.get:
	@echo "#GLASSFISH: Fishing"
	@sh .scripts/fetchGlassfish.sh

gf31.rmzip:
	@echo "#GLASSFISH: Removing zip"
	@rm -rf glassfish-3.1.1.zip

gf31.unzip:
	@echo "#GLASSFISH: Installing"
	@unzip glassfish-3.1.1.zip;mv glassfish3 bibigf31

appserver.get:
	@echo "#APPSERVER_CONFIG: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/appserver_config

appserver.createconfigs:
	@echo "#APPSERVER_CONFIG: Creating configs"
	@echo "catalina.home=`pwd`/bibigf31\ndomain.dir=${DOMAINDIR}\ndomain=bibidomain\nadmin.user=admin\nspool.dir=${TMPDIR}/spool\nexecutable.dir=${DOMAINDIR}/bibidomain/bin\nserver.portbase=8000\ndb.port=8027\nadmin.port=8048" > appserver_config/local.configuration
	@echo "AS_ADMIN_PASSWORD=admin\nAS_ADMIN_MASTERPASSWORD=changeit" > appserver_config/local.passwordfile

appserver.run:
	@echo "#GLASSFISH: Configuring and startup"
	@mkdir -p ${TMPDIR}
	@mkdir -p ${DOMAINDIR}
	@bash -c "cd appserver_config; ant ${ANTARGS} configure start"

appserver.kill:
	@echo "#GLASSFISH: Killing"
	@sh .scripts/kill_bibiserv.sh

appserver.clean:
	@echo "#APPSERVER_CONFIG: Cleaning"
	@bash -c "cd base; rm -rf lib; ant ${ANTARGS} clean-cache -q"

bibimainapp.get:
	@echo "#BIBIMAINAPP: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/bibimainapp

bibimainapp.dist:
	@echo "#BIBIMAINAPP: Compiling"
	@bash -c "cd bibimainapp; ant ${ANTARGS} clean dist"

bibimainapp.run: bibimainapp.dist
	@echo "#BIBIMAINAPP: Deploying"
	@bibigf31/bin/asadmin --user admin --passwordfile appserver_config/local.passwordfile --port 8048 --host localhost deploy --force --contextroot "" bibimainapp/dist/bibimainapp.war

bibimainapp.clean:
	@echo "#BIBIMAINAPP: Cleaning"
	@bash -c "cd bibimainapp; ant ${ANTARGS} clean-all clean-cache -q"

deploy: bibimainapp.run

resources.get:
	@echo "#INSTANTBIBI: clone resources"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/tools/instantbibi_resources

tool: guugle

guugle: codegen.do guugle.do guugle.deploy

dialign: codegen.do dialign.do dialign.deploy

guugle.deploy: 
	@echo "#TOOL: Deploying guugle"	
	@bash -c "cp instantbibi_resources/src/guugle-1.2.src.tar.gz ${TMPDIR}/`ls ${TMPDIR} | grep guugle`/resources/downloads/guugle-1.2.src.tar.gz"
	@bash -c "cd ${TMPDIR}/guugle*; ant ${ANTARGS} deploy"

dialign.deploy: 
	@echo "#TOOL: Deploying dialign"
	bash -c "cp instantbibi_resources/src/dialign-2.2.1-src.tar.gz ${TMPDIR}/`ls ${TMPDIR} | grep dialign`/resources/downloads/dialign-2.2.1-src.tar.gz"
	@bash -c "cd ${TMPDIR}/dialign_*; ant ${ANTARGS} deploy"

codegen.get:
	@echo "#CODEGEN: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/codegen

codegen.do: codegen.clean
	@echo "#CODEGEN: Installation into local ivy repository"
	@bash -c "cd codegen; ant ${ANTARGS} dist publish -q"

codegen.clean:
	@echo "#CODEGEN: Cleaning"
	@bash -c "cd codegen; ant ${ANTARGS} clean-all clean-cache -q"

base.get:
	@echo "#BASE: Cloning"
	@hg clone ssh://hg@hg.cebitec.uni-bielefeld.de/bibiadm/bibiserv2/main/base

guugle.do:
	@echo "#BASE: Generating guugle tool"
	@bash -c "TMP_DIR=${TMPDIR};export TMP_DIR; rm -rf /${TMPDIR}/guugle*; cd base; ant ${ANTARGS} clean-cache; rm -rf lib;ant ${ANTARGS} -Dxml=../codegen/testdata/guugle.bs2 "

dialign.do:
	@echo "#BASE: Generating dialign tool"
	@bash -c "TMP_DIR=${TMPDIR};export TMP_DIR; rm -rf /${TMPDIR}/dialign*; cd base; ant ${ANTARGS} clean-cache; rm -rf lib;ant ${ANTARGS} -Dxml=../codegen/testdata/dialign.bs2"

base.clean:
	@echo "#BASE: Cleaning"
	@bash -c "cd base; ant ${ANTARGS} clean-all clean-cache -q"

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
	@rm -rf glassfish* bibigf31 appserver_config bibimainapp base codegen logs instantbibi_resources ${HOME}/.bibiser2_manager

inst.antopt:
	@echo "#INSTALL ant ${ANTARGS} optional libs to ${HOME}/.ant/lib"
	@mkdir -p ${HOME}/.ant/lib
	@cp .ant/lib/*.jar ${HOME}/.ant/lib

binaries.install :
	@echo "#INSTALL (platform depended) binaries to ${DOMAINDIR}/bibidomain"
	@.scripts/install_binaries ${DOMAINDIR}/bibidomain/bin
