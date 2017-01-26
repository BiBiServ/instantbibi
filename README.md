# Instantbibi

[![CircleCI](https://circleci.com/gh/BiBiServ/instantbibi.svg?style=svg)](https://circleci.com/gh/BiBiServ/instantbibi)

## Description

InstantBiBi is a configuration tool to set up a complete BiBiServ2 environment.

## Requirements

* ant >= 1.8

* Java 8

* docker (If you are an administrator)

## How to use

Before you run any commands, please run

~~~BASH
ant install.antlib
~~~

### How to use instantbibi as a tool developer


##### Start the instantbibi wizard for creating a tool description

~~~BASH
ant instant.environment && ant install.wizard
~~~

This command starts the wizard on localhost:8080/wizard.
With the help of the wizard you can create tool description (runnableitem.xml) that 
you must place in the GitHub repository of your tool.
Your Github repository must contain a Dockerfile and a runnableitem.xml in the root directory.

(For an installation of your tool, please provide a link of your github repository 
to the administrator of the bibiserv) 

###### Options

* -Dbase.dir=<dir> lets you change the default domain directory. Default: /tmp/${user.name}

##### Uninstall your wizard installation

You can remove your installation with 

~~~BASH
ant wipe.all
~~~

### How to use instantbibi as a service administrator

##### Start your own bibiserv

You can configure the deployment of your installation with the help of the [resources.config](resources.config)
file. 

(If you maintain a fork of the bibiserv, you could change the default bibiserv url or the server_config
property for a different layout.)

After that step you can run 

~~~BASH
ant instant 
~~~

to deploy your application. This command will automatically fetch a glassfish 
and deploy the bibimainapp. You can view the start page on localhost:8080.
It will create the bibidomain in /tmp/${user.name}.

The default admin credentials are **testadmin** and **simplepassword**
When you have logged in you can change the BiBiTools properties which defines for example the Docker Hub Organisation that
is used for the deployed tools. 

###### Options

* -Dbase.dir=<dir> lets you change the default domain directory. Default: /tmp/${user.name}

* -Dspool.dir=<dir> defines the work directory for the installed tools. Default: ${base.dir}/spool

* -Dportbase=<port> sets the portbase for the installation. Starting from this port base the following 4 ports used:

   * ${portbase} + 80  (http) 

   * ${portbase} + 81  (https)

   * ${portbase} + 27  (database port)

   * ${portbase} + 48  (administration port)


##### Deploy a tool on your service instance

You can deploy a tool with the following command

~~~BASH
ant deploy.docker -Durl=<github-url> -Drelease=<release> -Ddest=<destination-path>
~~~

where

* **github-url** is a url to a repository which must have at least the runnableitem.xml (produced by the bibiserv wizard)
 and a Dockerfile in the root directory. Example: https://github.com/BiBiServ/dialign-docker 

* **release** is a release number of your tool. You can provide 'master' for using the master branch. 
Example: '2.2.1'

* **dest** is the destination path of the tool project directory. This directory is just for the intermediate steps important
and you can remove it afterwards. Example: /tmp/test

This command will also ask you for your dockerhub credentials. It will deploy the tool on your running glassfish (created with ant instant)
 and it will push the docker image to the provided dockerhub account. 
 You can view the tool by pointing your browser to localhost:8080/toolname.  

A working command looks like this:

~~~BASH
ant deploy.docker -Durl=https://github.com/BiBiServ/dialign-docker -Drelease=master -Ddest=/tmp/test
~~~

If you want to skip the docker step, you can run 'ant deploy.github' with the same parameters as deploy.docker and push your image afterwards.

##### Inspect the configuration of your service.

You can view the configuration with 

~~~BASH
ant showconfig
~~~


##### Undeploy a tool of your service.

You can undeploy your tool with 

~~~BASH
ant undeploy.app -Dapp=<toolname>
~~~


##### Uninstall your service installation

You can undeploy your installation with 

~~~BASH
ant wipe.all
~~~
