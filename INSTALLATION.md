# Installation Instructions

## Overview

These instructions are for installing a [PostgreSQL][PostgreSQL] relational
database management system using [docker containers][docker]. Additionally, the
schemas and data for the DTOcean example and template databases are loaded,
which include the [PostGIS][PostGIS] geospatial extension. To connect to the
database use your computer's local hostname and the configured port (e.g.
`'host=localhost port=5432'`).

The [pgAdmin][pgAdmin] database administration software is also installed and
can be accessed via a web browser using your computer's local hostname and the
configured port (e.g. `localhost:8080`).

## Prerequisites

### Installation files

Download a copy of the installation files as a zip or tar.gz archive from the
latest release page:

<https://github.com/DTOcean/dtocean-database-next/releases/latest>

Decompress the archive to a location of your choosing.

### Container management software

A container management system with support for [Docker Compose][Compose] is
required. On Windows computers, [Docker Desktop][Desktop] is recommended. To
avoid signing up in order to download Docker Desktop, use the link below:

<https://docs.docker.com/get-started/introduction/get-docker-desktop/>

Other container management systems can be used, such as [podman][podman],
although the performance of the database using podman on Windows was much
slower than Docker Desktop. For other OSes this performance deficit may not
occur.

### Terminal

These instructions require issuing commands in a command terminal. Familiarity
with using a terminal is required. Some examples of terminal programs are:

+ Windows
  + [Command Prompt][cmd]
  + [PowerShell][PowerShell]
+ Linux
  + [Bash][Bash]

## Install

### Environment Variables

Required and optional environment variables must be set prior to running the
installation. The variable names, their meanings, and whether they are required
or not, is shown in the table below.

| Name                     | Description                                      | Required | Default          |
|--------------------------|--------------------------------------------------|----------|------------------|
| DTOCEAN_USER_PASSWORD    | Password for the databases owner's account       | Yes      |                  |
| POSTGRES_PASSWORD        | Password for the postgres super user account     | Yes      |                  |
| DTOCEAN_DB_EXAMPLES_NAME | Name of the DTOcean examples database            | No       | dtocean_examples |
| DTOCEAN_DB_TEMPLATE_NAME | Name of the DTOcean template database            | No       | dtocean_template |
| DTOCEAN_USER_NAME        | User name for the databases owner's account      | No       | dtocean_user     |
| PGADMIN_PORT             | Port to use to access pgadmin on localhost       | No       | 8080             |
| POSTGRES_PORT            | Port to use to access the databases on localhost | No       | 5432             |

It is recommended to set the environment variables directly in the terminal.
The commands differs per terminal. For instance:

#### Command Prompt (Windows)

```bat
set POSTGRES_PASSWORD="postgres"
```

#### PowerShell (Windows)

```pwsh
$env:POSTGRES_PASSWORD="postgres"
```

#### Bash (Linux)

```sh
POSTGRES_PASSWORD="postgres"
```

Alternatively, variable values can be set in the included `.env` file. A
description of the syntax of this file is available at the following link:

<https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#env-file-syntax>

When updating this file **DO NOT** delete the `DTOCEAN_DB_VERSION` variable, as
this is required to work with the DTOcean tools. Also **DO NOT** commit this
file to any version control system. That is a [bad thing to do][bad].

### Build and start the container

Using the same terminal session with the environment variables set (as
described in the previous section), move the working directory to the root of
the installation files folder, e.g.

```sh
cd path/to/downloads/dtocean-database-v2025.04.0
```

Now use Docker Compose to build and start the container:

```sh
docker compose -f docker-compose.yml -f docker-compose.build.yml up -d
```

This starts the container in 'detached' mode (due to the `-d` flag), which will
run as a background process. To check that the container is working correctly,
use the `docker ps` command, which should produce output similar to the
following:

```sh
$ docker ps
NAME                                   IMAGE                                COMMAND                  SERVICE    CREATED          STATUS          PORTS
dtocean-database-v2025040-database-1   dtocean-database-v2025040-database   "docker-entrypoint.s…"   database   11 seconds ago   Up 10 seconds   0.0.0.0:5433->5432/tcp
dtocean-database-v2025040-pgadmin-1    dtocean-database-v2025040-pgadmin    "/entrypoint.sh"         pgadmin    11 seconds ago   Up 10 seconds   443/tcp, 0.0.0.0:8081->80/tcp
```

Alternatively, when using Docker Desktop the [Containers view][Explore] can be
used to check the status of all your containers and applications.

Once the container has started, it will begin a one time initialization to
build the DTOcean databases. This process requires typically between 2 and 3
minutes after which the database service will restart. The DTOcean databases
will not be accessible prior to completion of this process.

## Starting and Stopping

Building the container is only required once. To start an existing container
using docker compose in a terminal, issue the following command from the root
of the installation files directory:

```sh
docker compose -f docker-compose.yml start
```

To stop running containers, issue the follow command:

```sh
docker compose -f docker-compose.yml stop
```

Alternatively, when using Docker Desktop the Containers view can be used to
start and stop containers.

## Uninstall

To uninstall a container using docker compose in a terminal, issue the
following command from the root of the installation files directory:

```sh
docker compose -f docker-compose.yml down --rmi 'all' -v
```

This will remove all artifacts created when the container was built, including
images and volumes. To achieve the same effect using Docker Desktop, start by
stopping and deleting the containers in the Containers view, followed by the
associated images in the Images view and, finally, the volumes in the Volumes
view.

[PostgreSQL]: https://www.postgresql.org/
[docker]: https://www.docker.com/resources/what-container/
[PostGIS]: https://postgis.net/
[pgAdmin]: https://www.pgadmin.org/
[Compose]: https://docs.docker.com/compose/
[Desktop]: https://www.docker.com/products/docker-desktop/
[podman]: https://podman.io/
[cmd]: https://en.wikipedia.org/wiki/Cmd.exe
[PowerShell]: https://learn.microsoft.com/en-us/powershell/
[Bash]: https://www.gnu.org/software/bash/
[bad]: https://cyble.com/blog/widespread-cloud-exposure/
[Explore]: https://docs.docker.com/desktop/use-desktop/
