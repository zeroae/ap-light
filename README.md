# zeroae/ap-light

[![Docker Pulls](https://img.shields.io/docker/pulls/zeroae/ap-light.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/zeroae/ap-light.svg)][hub]
[![](https://images.microbadger.com/badges/image/zeroae/ap-light.svg)](http://microbadger.com/images/zeroae/ap-light "Get your own image badge on microbadger.com")

[hub]: https://hub.docker.com/r/zeroae/ap-light/

Latest release: 0.5.0 -  [Changelog](CHANGELOG.md)
 | [Docker Hub](https://hub.docker.com/r/zeroae/ap-light/) 

A Debian Jessie based image to quickly build reliable images based on Joyent's ContainerPilot pattern. This image provides a simple opinionated solution to build single process image with minimum of layers and an optimized build.

The aims of this image is to be used as a base for your own Docker images. It's based on the awesome work of: 
- [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
- [osixia/docker-light-baseimage](https://github.com/osixia/docker-light-baseimage)
- [joyent/containerpilot](https://github.com/joyent/containerpilot)

## Table of Contents
- [Contributing](#contributing)
- [Overview](#overview)
- [Quick Start](#quick-start)
	- [Image directories structure](#image-directories-structure)
	- [Service directory structure](#service-directory-structure)
	- [Create a single process image](#create-a-single-process-image)
		- [Overview](#create-a-single-process-image)
		- [Dockerfile](#dockerfile)
		- [Service files](#service-files)
		- [Environment files](#environment-files)
		- [Build and test](#build-and-test)
- [Images Based On Autopilot-Light-Baseimage](#images-based-on-light-baseimage)
- [Image Assets](#image-assets)
	- [Tools](#image-assets)
	- [Services available](#services-available)
- [Advanced User Guide](#advanced-user-guide)
	- [Service available](#service-available)
	- [Fix docker mounted file problems](#fix-docker-mounted-file-problems)
  	- [Distribution packages documentation and locales](#distribution-packages-documentation-and-locales)
	- [Mastering image tools](#mastering-image-tools)
		- [run](#run)
            - [Run command line options](#run-command-line-options)
			- [Run directory setup](#run-directory-setup)
			- [Startup files environment setup](#startup-files-environment-setup)
			- [Startup files execution](#startup-files-execution)
			- [ Process environment setup](#process-environment-setup)
			- [Process execution](#process-execution)
				- [Single process image](#single-process-image)
				- [Multiple process image](#multiple-process-image)
				- [No process image](#no-process-image)
			- [Extra environment variables](#extra-environment-variables)
		- [log-helper](#log-helper)
		- [complex-bash-env](#complex-bash-env)
	- [Tests](#tests)
- [Changelog](#changelog)

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your kickass new features and bug fixes
- Help new users with [issues](https://github.com/zeroae/ap-light/issues) they may encounter
- Support the development of this image and star this repo!

## Overview

This image takes all the advantages of [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) but makes programs optional which allow more lightweight images and single process images. It also define simple directory structure and files to quickly set how a program (here called service) is installed, setup and run.

So major features are:
 - Greats building tools to minimize the image number of layers and optimize image build.
 - Simple way to install services and multiple process image stacks (runit, cron, syslog-ng-core and logrotate) if needed.
 - Getting environment variables from **.yaml** and **.json** files.
 - Special environment files **.startup.yaml** and **.startup.json** deleted after image startup files first execution to keep the image setup secret.


## Quick Start

### Image directories structure

This image use four directories:

- **/opt/ap/environment**: for environment files.
- **/opt/ap/service**: for services to install, setup and run.
- **/opt/ap/service-available**: for service that may be on demand downloaded, installed, setup and run.
- **/opt/ap/tool**: for image tools.

By the way at run time another directory is created:
- **/opt/ap/run**: To store container run environment, state, startup files and process to run based on files in  /opt/ap/environment and /opt/ap/service directories.

But this will be dealt with in the following section.

### Service directory structure

This section define a service directory that can be added in /opt/ap/service or /opt/ap/service-available.

- **my-service**: root directory
- **my-service/bin**: binaries and utilities which are moved to /opt/ap/bin
- **my-service/containerpilot.d**: containerpilot configuration JSON files (.json) or templates (.json.cptmpl).
- **my-service/consul.d**: consul agent configuration JSON files (not mandatory)
- **my-service/install.sh**: install script (not mandatory).
<!--
- **my-service/startup.sh**: startup script to setup the service when the container start (not mandatory).
- **my-service/process.sh**: process to run (not mandatory).
- **my-service/finish.sh**: finish script run when the process script exit (not mandatory).
-->
- **my-service/...** add whatever you need!

Ok that's pretty all to know to start building our first images!

### Create a single process image

#### Overview
For this example we are going to perform a basic nginx install.

See complete example in: [example/single-process-image](example/single-process-image)

First we create the directory structure of the image:

 - **single-process-image**: root directory
 - **single-process-image/service**: directory to store the nginx service.
 - **single-process-image/environment**: environment files directory.
 - **single-process-image/Dockerfile**: the Dockerfile to build this image.

**service** and **environment** directories name are arbitrary and can be changed but make sure to adapt their name everywhere and especially in the Dockerfile.

Let's now create the nginx service directory:

 - **single-process-image/service/nginx**: service root directory
 - **single-process-image/service/nginx/install.sh**: service installation script.
 - **single-process-image/service/nginx/startup.sh**:  startup script to setup the service when the container start.
 - **single-process-image/service/nginx/process.sh**: process to run.


#### Dockerfile

In the Dockerfile we are going to:
  - Download nginx from apt-get.
  - Add the service directory to the image.
  - Install service and clean up.
  - Add the environment directory to the image.
  - Define ports exposed and volumes if needed.


        # Use osixia/light-baseimage
        # https://github.com/osixia/docker-light-baseimage
        FROM osixia/light-baseimage:0.2.6
        MAINTAINER Your Name <your@name.com>

        # Download nginx from apt-get and clean apt-get files
        RUN apt-get -y update \
            && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
               nginx \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

        # Add service directory to ${AP_ROOT}/service
        ADD service ${AP_ROOT}/service

        # Use baseimage ap-service-install script
        # https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/ap-service-install
        RUN ap-service-install

        # Add default env directory
        ADD environment ${AP_ROOT}/environment/99-default

        # Set /var/www/ in a data volume
        VOLUME /var/www/

        # Expose default http and https ports
        EXPOSE 80 443


The Dockerfile contains directives to download nginx from apt-get but all the initial setup will take place in install.sh file (called by ap-service-install tool) for a better build experience. The time consuming download task is decoupled from the initial setup to make great use of docker build cache. If install.sh file is changed the builder won't have to download again nginx, and will just run install scripts.

#### Service files

##### install.sh

This file must only contain directives for the service initial setup. Files download and apt-get command takes place in the Dockerfile for a better image building experience (see [Dockerfile](#dockerfile)).

In this example, for the initial setup we just delete the default nginx debian index file and create a custom index.html:

    #!/bin/bash -e
    # this script is run during the image build

    rm -rf /var/www/html/index.nginx-debian.html
    echo "Hi!" > /var/www/html/index.html

Make sure install.sh can be executed (chmod +x install.sh).

Note: The install.sh script is run during the docker build so run time environment variables can't be used to customize the setup. This is done in the startup.sh file.


##### startup.sh

This file is used to make process.sh ready to be run and customize the service setup based on run time environment.

For example at run time we would like to introduce ourselves so we will use an environment variable WHO_AM_I set by command line with --env. So we add WHO_AM_I value to index.html file but we want to do that only on the first container start because on restart the index.html file will already contains our name:

    #!/bin/bash -e
    FIRST_START_DONE="${CONTAINER_STATE_DIR}/nginx-first-start-done"

    # container first start
    if [ ! -e "$FIRST_START_DONE" ]; then
      echo "I'm ${WHO_AM_I}."  >> /var/www/html/index.html
      touch $FIRST_START_DONE
    fi

    exit 0

Make sure startup.sh can be executed (chmod +x startup.sh).

As you can see we use CONTAINER_STATE_DIR variable, it contains the directory where container state is saved, this variable is automatically set by run tool. Refer to the [Advanced User Guide](#extra-environment-variables) for more information.

##### process.sh

This file define the command to run:

    #!/bin/bash -e
    exec /usr/sbin/nginx -g "daemon off;"

Make sure process.sh can be executed (chmod +x process.sh).

*Caution: The command executed must start a foreground process otherwise the container will immediately stops.*

That why we run nginx with `-g "daemon off;"`

That's it we have a single process image that run nginx!
We could already build and test this image but two more minutes to take advantage of environment files!

#### Environment files

Let's create two files:
 - single-process-image/environment/default.yaml
 - single-process-image/environment/default.startup.yaml

File name *default*.yaml and *default*.startup.yaml can be changed as you want. Also in this example we are going to use yaml files but json files works too.

##### default.yaml
default.yaml file define variables that can be used at any time in the container environment:

    WHO_AM_I: We are Anonymous. We are Legion. We do not forgive. We do not forget. Expect us.

##### default.startup.yaml
default.startup.yaml define variables that are only available during the container **first start** in **startup files**.
\*.startup.yaml are deleted right after startup files are processed for the first time,
then all variables they contains will not be available in the container environment.

This helps to keep the container configuration secret. If you don't care all environment variables can be defined in **default.yaml** and everything will work fine.

But for this tutorial we will add a variable to this file:

    FIRST_START_SETUP_ONLY_SECRET: The database password is KawaaahBounga

And try to get its value in **startup.sh** script:

    #!/bin/bash -e
    FIRST_START_DONE="${CONTAINER_STATE_DIR}/nginx-first-start-done"

    # container first start
    if [ ! -e "$FIRST_START_DONE" ]; then
      echo ${WHO_AM_I}  >> /var/www/html/index.html
      touch $FIRST_START_DONE
    fi

    echo "The secret is: $FIRST_START_SETUP_ONLY_SECRET"

    exit 0

And in **process.sh** script:

    #!/bin/bash -e
    echo "The secret is: $FIRST_START_SETUP_ONLY_SECRET"
    exec /usr/sbin/nginx -g "daemon off;"

Ok it's time for the show!

#### Build and test

Build the image:

	docker build -t example/single-process --rm .

Start a new container:

    docker run -p 8080:80 example/single-process

Inspect the output and you should see that the secret is present in startup script:
> \*\*\* Running /opt/ap/run/startup/nginx...

> The secret is: The database password is Baw0unga!

And the secret is not defined in the process:
> \*\*\* Remove file /opt/ap/environment/99-default/default.startup.yaml [...]

> \*\*\* Running /opt/ap/run/process/nginx/run...

> The secret is:

Yes in this case it's not really useful to have a secret variable like this, but a concrete example can be found in [osixia/openldap](https://github.com/osixia/docker-openldap) image.
The admin password is available in clear text during the container first start to create a new ldap database where it is saved encrypted. After that the admin password is not available in clear text in the container environment.

Ok let's check our name now, go to [http://localhost:8080/](http://localhost:8080/)

You should see:
> Hi! We are Anonymous. We are Legion. We do not forgive. We do not forget. Expect us.

And finally, let's say who we really are, stop the previous container (ctrl+c or ctrl+d) and start a new one:

    docker run --env WHO_AM_I="I'm Jon Snow, what?! i'm dead?" \
    -p 8080:80 example/single-process

Refresh [http://localhost:8080/](http://localhost:8080/) and you should see:
> Hi! I'm Jon Snow, what?! i'm dead?


##### Overriding default environment files at run time:
Let's create two new environment files:
  - single-process-image/test-custom-env/env.yaml
  - single-process-image/test-custom-env/env.startup.yaml

env.yaml:

    WHO_AM_I: I'm bobby.

env.startup.yaml:

    FIRST_START_SETUP_ONLY_SECRET: The database password is KawaaahB0unga!!!

And we mount them at run time:

    docker run --volume $PWD/test-custom-env:/opt/ap/environment/01-custom \
    -p 8080:80 example/single-process

Take care to link your environment files folder to `/opt/ap/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/opt/ap/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

In the output:
> \*\*\* Running /opt/ap/run/startup/nginx...

> The secret is: The database password is KawaaahB0unga!!!

Refresh [http://localhost:8080/](http://localhost:8080/) and you should see:
> Hi! I'm bobby.


## Images Based On Light-Baseimage

Single process images:
- [zeroae/ap-your-image-here](https://github.com/zeroae/your-image-here)

Image adding light-baseimage tools to an existing image
- [osixia/gitlab](https://github.com/osixia/docker-gitlab)

Send me a message to add your image in this list.

## Image Assets

### Tools

All container tools are available in `/opt/ap/bin` and is added to the container PATH in the base image.


| Filename        | Description |
| ---------------- | ------------------- |
| ap-service-add | A tool to download and add services in service-available directory to the regular service directory. |
| ap-service-install | A tool that execute /opt/ap/service/install.sh and /opt/ap/service/\*/install.sh scripts. |
| ap-spin | A tool that spins, it is default application executed by containerpilot. |
| log-helper | A simple bash tool to print message base on the log level. |
| run | The run tool is defined as the image ENTRYPOINT (see [Dockerfile](image/Dockerfile)). It set environment and run  startup scripts and images process. More information in the [Advanced User Guide](#run). |
| setuser | A tool for running a command as another user. Easier to use than su, has a smaller attack vector than sudo, and unlike chpst this tool sets $HOME correctly.|
| complex-bash-env | A tool to iterate trough complex bash environment variables created by the run tool when a table or a list was set in environment files or in environment command line argument. |

### Services available

| Name        | Description |
| ---------------- | ------------------- |
| :ssl-tools | Add CFSSL a CloudFlare PKI/TLS swiss army knife. It's a command line tool for signing, verifying, and bundling TLS certificates. Comes with cfssl-helper tool that make it docker friendly by taking command line parameters from environment variables. <br><br>Also add jsonssl-helper to get certificates from json files, parameters are set by environment variables. |


## Advanced User Guide

### Service available

A service-available is basically a normal service expect that it is in the `service-available` directory and have a `download.sh` file.

To add a service-available to the current image use the `ap-service-add` tool. It will process the download.sh file of services given in argument and move them to the regular service directory (/opt/ap/service).

After that the service-available will be process like regular services.

Here simple Dockerfile example how to add a service-available to an image:

        # Use osixia/light-baseimage
        # https://github.com/osixia/docker-light-baseimage
        FROM osixia/light-baseimage:0.2.6
        MAINTAINER Your Name <your@name.com>

        # Add cfssl and cron service-available
        # https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/ap-service-add
        # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
        # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:cron/download.sh
        RUN apt-get -y update \
            && ap-service-add :ssl-tools :cron \
            && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
               nginx \
               php5-fpm
        ...


Note: Most of predefined service available start with a `:` to make sure they are installed before regular services (so they can be used by regular services). The `ap-service-install` tool process services in /opt/ap/service in alphabetical order.

To create a service-available just create a regular service, add a download.sh file to set how the needed content is downloaded and add it to /opt/ap/service-available directory. The download.sh script is not mandatory if nothing need to be downloaded.

For example a simple image example that add service-available to this baseimage: [osixia/web-baseimage](https://github.com/osixia/docker-web-baseimage)


### Fix docker mounted file problems

For some reasons you will probably have to mount custom files to your container. For example in the *mutliple process image example* you can customise the nginx config by mounting your custom config to "/opt/ap/service/php5-fpm/config/default" :

    docker run -v /data/my-nginx-config:/opt/ap/service/php5-fpm/config/default example/multiple-process

In this case every thing should work fine, but if the startup script makes some `sed` replacement or change file owner and permissions this can results in "Device or resource busy" error. See [Docker documentation](https://docs.docker.com/v1.4/userguide/dockervolumes/#mount-a-host-file-as-a-data-volume).

    sed -i "s|listen 80|listen 8080|g" /opt/ap/service/php5-fpm/config/default

To prevent that king of error light-baseimage provide *--copy-service* command argument :

    docker run -v /data/my-nginx-config:/opt/ap/service/php5-fpm/config/default example/multiple-process --copy-service

On startup this will copy all /opt/ap/service directory to /opt/ap/run/service.


At run time you can get the container service directory with `CONTAINER_SERVICE_DIR` environment variable.
If *--copy-service* is used *CONTAINER_SERVICE_DIR=/opt/ap/run/service* otherwise *CONTAINER_SERVICE_DIR=/opt/ap/service*

So to always apply sed on the correct file in the startup script the command becomes :

    sed -i "s|listen 80|listen 8080|g" ${CONTAINER_SERVICE_DIR}/php5-fpm/config/default


### Distribution packages documentation and locales

This image has a configuration to prevent documentation and locales to be installed from base distribution packages repositories to make it more lightweight as possible. If you need the doc and locales remove the following files :
**/etc/dpkg/dpkg.cfg.d/01_nodoc** and **/etc/dpkg/dpkg.cfg.d/01_nolocales**


### Mastering image tools

#### run

The *run tool* is defined as the image ENTRYPOINT (see [Dockerfile](image/Dockerfile)). It's the core tool of this image.

What it does:
- Setup the run directory
- Set the startup files environment
- Run startup files
- Set process environment
- Run process

##### Run command line options

*Run tool* takes several options, to list them:

    docker run osixia/light-baseimage:0.2.6 --help
    usage: run [-h] [-e] [-s] [-p] [-f] [-o {startup,process,finish}]
               [-c COMMAND [WHEN={startup,process,finish} ...]] [-k]
               [--wait-state FILENAME] [--wait-first-startup] [--keep-startup-env]
               [--copy-service] [--dont-touch-etc-hosts] [--keepalive]
               [--keepalive-force] [-l {none,error,warning,info,debug,trace}]
               [MAIN_COMMAND [MAIN_COMMAND ...]]

    Initialize the system.

    positional arguments:
      MAIN_COMMAND          The main command to run, leave empty to only run
                            container process.

    optional arguments:
      -h, --help            show this help message and exit
      -e, --skip-env-files  Skip getting environment values from environment
                            file(s).
      -s, --skip-startup-files
                            Skip running /opt/ap/run/startup/* and
                            /opt/ap/run/startup.sh file(s).
      -p, --skip-process-files
                            Skip running container process file(s).
      -f, --skip-finish-files
                            Skip running container finish file(s).
      -o {startup,process,finish}, --run-only {startup,process,finish}
                            Run only this file type and ignore others.
      -c COMMAND [WHEN={startup,process,finish} ...], --cmd COMMAND [WHEN={startup,process,finish} ...]
                            Run this command before WHEN file(s). Default before
                            startup file(s).
      -k, --no-kill-all-on-exit
                            Don't kill all processes on the system upon exiting.
      --wait-state FILENAME
                            Wait until the container state file exists in
                            /opt/ap/run/state directory before starting.
                            Usefull when 2 containers share /opt/ap/run
                            directory via volume.
      --wait-first-startup  Wait until the first startup is done before starting.
                            Usefull when 2 containers share /opt/ap/run
                            directory via volume.
      --keep-startup-env    Don't remove ('.startup.yaml', '.startup.json')
                            environment files after startup scripts.
      --copy-service        Copy /opt/ap/service to /opt/ap/run/service.
                            Help to fix docker mounted files problems.
      --dont-touch-etc-hosts
                            Don't add in /etc/hosts a line with the container ip
                            and $HOSTNAME environment variable value.
      --keepalive           Keep alive container if all startup files and process
                            exited without error.
      --keepalive-force     Keep alive container in all circonstancies.
      -l {none,error,warning,info,debug,trace}, --loglevel {none,error,warning,info,debug,trace}
                            Log level (default: info)

    Osixia! Light Baseimage: https://github.com/osixia/docker-light-baseimage


##### Run directory setup
*Run tool* will create if they not exists the following directories:
  - /opt/ap/run/state
  - /opt/ap/run/environment
  - /opt/ap/run/startup
  - /opt/ap/run/process
  - /opt/ap/run/service

At the container first start it will search in /opt/ap/service or /opt/ap/run/service (if --copy-service option is used) all image's services.

In a service directory for example /opt/ap/service/my-service:
  - If a startup.sh file is found, the file is linked to /opt/ap/run/startup/my-service
  - If a process.sh file is found, the file is linked to /opt/ap/run/process/my-service/run

##### Startup files environment setup
*Run tool* takes all file in /opt/ap/environment/* and import the variables values to the container environment.
The container environment is then exported to /opt/ap/run/environment and in /opt/ap/run/environment.sh

##### Startup files execution
*Run tool* iterate trough /opt/ap/run/startup/* directory in alphabetical order and run scripts.
After each time *run tool* runs a startup script, it resets its own environment variables to the state in /opt/ap/run/environment, and re-dumps the new environment variables to /opt/ap/run/environment.sh

After all startup script *run tool* run /opt/ap/run/startup.sh if exists.

##### Process environment setup
*Run tool* delete all .startup.yaml and .startup.json in /opt/ap/environment/* and clear the previous run environment (/opt/ap/run/environment is removed)
Then it takes all remaining file in /opt/ap/environment/* and import the variables values to the container environment.
The container environment is then exported to /opt/ap/run/environment and in /opt/ap/run/environment.sh

##### Process execution

###### Single process image

*Run tool* execute the unique /opt/ap/run/process/service-name/run file.

If a main command is set for example:

    docker run -it osixia/openldap:1.1.0 bash

*Run tool* will execute the single process and the main command. If the main command exits the container exits. This is useful to debug or image development purpose.

###### Multiple process image

In a multiple process image *run tool* execute runit witch supervise /opt/ap/run/process directory and start all services automatically. Runit will also relaunched them if they failed.

If a main command is set for example:

    docker run -it osixia/phpldapadmin:0.6.7 bash

*run tool* will execute runit and the main command. If the main command exits the container exits. This is still useful to debug or image development purpose.

###### No process image
If a main command is set *run tool* launch it otherwise bash is launched.
Example:

    docker run -it osixia/light-baseimage:0.2.6


##### Extra environment variables

*run tool* add 3 variables to the container environment:
- **CONTAINER_STATE_DIR**: /opt/ap/run/state
- **CONTAINER_SERVICE_DIR**: the container service directory. By default: /opt/ap/service but if the container is started with --copy-service option: /opt/ap/run/service
- **CONTAINER_LOG_LEVEL**: log level set by --loglevel option defaults to: 3 (info)

#### log-helper
This tool is a simple utility based on the CONTAINER_LOG_LEVEL variable to print leveled log messages.

For example if the log level is info:

    log-helper info hello

will echo:
> hello

    log-helper debug i'm bob

will echo nothing.

log-helper support piped input:

    echo "Heyyyyy" | log-helper info

> Heyyyyy

Log message functions usage: `log-helper error|warning|info|debug|trace message`

You can also test the log level with the level function:

    log-helper level eq info && echo "log level is infos"

for example this will echo "log level is trace" if log level is trace.

Level `function usage: log-helper level eq|ne|gt|ge|lt|le none|error|warning|info|debug|trace`
Help: [http://www.tldp.org/LDP/abs/html/comparison-ops.html](http://www.tldp.org/LDP/abs/html/comparison-ops.html)

#### complex-bash-env
With light-baseimage you can set bash environment variable from .yaml and .json files.
But bash environment variables can't store complex objects such as table that can be defined in yaml or json files, that's why they are converted to "complex bash environment variables" and complex-bash-env tool help getting those variables values easily.

For example the following yaml file:

      FRUITS:
        - orange
        - apple

will produce this bash environment variables:

      FRUITS=#COMPLEX_BASH_ENV:TABLE: FRUITS_ROW_1 FRUITS_ROW_2
      FRUITS_ROW_1=orange
      FRUITS_ROW_2=apple

(this is done by run tool)

complex-bash-env make it easy to iterate trough this variable:

      for fruit in $(complex-bash-env iterate FRUITS)
      do
        echo ${!fruit}
      done

A more complete example can be found [osixia/phpLDAPadmin](https://github.com/osixia/docker-phpLDAPadmin) image.

Note this yaml definition:

    FRUITS:
      - orange
      - apple

Can also be set by command line converted in python or json:

    docker run -it --env FRUITS="#PYTHON2BASH:['orange','apple']" osixia/light-baseimage:0.2.6 printenv
    docker run -it --env FRUITS="#JSON2BASH:[\"orange\",\"apple\"]" osixia/light-baseimage:0.2.6 printenv

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run:

	make test

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)
