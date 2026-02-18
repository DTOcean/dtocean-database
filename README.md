[![release](https://img.shields.io/github/release/DTOcean/dtocean-database-next.svg)](https://github.com/DTOcean/dtocean-database-next/releases/latest)
[![Test container startup](https://github.com/DTOcean/dtocean-database-next/actions/workflows/up.yaml/badge.svg)](https://github.com/DTOcean/dtocean-database-next/actions/workflows/up.yaml)

# The DTOcean Database

## Introduction

The DTOcean database is a [PostgreSQL](https://www.postgresql.org/) database
used for storing persistent data, such as ocean energy converter (OEC) designs,
metocean observations for sites, and reference data for electrical, mooring
and foundations components, ports, vessels, etc.

The pre-installed data shipped with the database contains free to use examples
of OECs, sites, and reference data. The included data was used in the
development of two scenarios that contributed to journal publications, as shown
in the table below.

| Scenario | Location                | Device | Device Type   | Publications                                      |
|----------|-------------------------|--------|---------------|---------------------------------------------------|
| 1        | Eureka, CA, USA         | RM3    | Floating Wave | [[1][topper2019reducing]]                         |
| 2        | Tacoma Narrows, WA, USA | RM1    | Fixed Tidal   | [[2][topper2020techno]] [[3][topper2021benefits]] |

## Installation

The recommended method for installing the latest version of the DTOcean
database is using [Docker Compose](https://docs.docker.com/compose/) to run the
database in a [container](https://www.docker.com/resources/what-container/).
Details on how to prepare your system to install containers is included in the
installation instructions.

Download the zip or tar.gz archive from the [latest
release](https://github.com/DTOcean/dtocean-database-next/releases/latest)
page, decompress the folder, and then follow the instructions in
[INSTALLATION.md](INSTALLATION.md). Note that a copy of the installation
instructions is also included in the archives.

If you are installing version v2.0.0 or v1.0.0 of the database then follow the
instructions in the `README_database_installation.txt` file found in the zip
archives. Beware that those instructions require outdated versions of
PostgreSQL.

## Documentation

Instructions for preparing data to be stored in the database and a description
of the database schema can be found in the [dtocean
documentation](https://dtocean.github.io/dtocean/main/user/data_preparation.html).

## Development

This repository uses [dvc](https://github.com/iterative/dvc) to manage copies
of the published data. The data, in csv format, is stored on a remote service
(external to GitHub) and the repository only contains dvc managed pointers to
the data. Commands provided by dvc are used to transfer the data to and from
the external remote.

Python is used to install dvc and for testing database initialization. The
[Poetry](https://python-poetry.org/) package manager is used to manage Python
dependencies. To prepare the repository for installation from source, first
clone it and [install Poetry](https://python-poetry.org/docs/#installation).
From the root of the repository use Poetry to install dependencies:

```sh
poetry install --with test
```

Now use [dvc pull](https://dvc.org/doc/command-reference/pull) to populate the
`export` folder with the database tables:

```sh
poetry run dvc pull
```

Follow the instructions in [INSTALLATION.md](INSTALLATION.md) to deploy the
docker container from your local git repo.

## Testing

The database container initialization typically requires between 2 and 3
minutes to complete. Tests developed with
[pytest](https://docs.pytest.org/en/stable/) are provided to test if the
initialization was successful.

Before running the tests, certain environment variables with values matching
those used when creating the containers (see the [Environment
Variables](INSTALLATION.md#environment-variables) section) must be defined. The
variables to include (if set) are:

+ DTOCEAN_DB_EXAMPLES_NAME
+ DTOCEAN_DB_TEMPLATE_NAME
+ DTOCEAN_USER_NAME
+ DTOCEAN_USER_PASSWORD
+ POSTGRES_PORT

Note that DTOCEAN_USER_PASSWORD is the only variable used here which is
required to be set during the installation process. Once the variables are set,
call the following command to run the tests:

```sh
poetry run pytest tests
```

## Contributing

Contributions are gratefully received and should be provided using pull
requests. To contribute additional data, you must set up a temporary DVC
[remote](https://dvc.org/doc/user-guide/data-management/remote-storage#remote-storage)
to share the data and make sure to check the '[Allow edits from
maintainers][allowedits]' option in the pull request. Alternatively, open an
issue to discuss other methods for transmitting the data.

## Credits

This database was initially created as part of the [EU DTOcean project](
https://www.dtoceanplus.eu/About-DTOceanPlus/History) by:

+ Chris O’Donoghue at [University College Cork](https://www.ucc.ie/)
+ Mathew Topper at [TECNALIA](https://www.tecnalia.com)
+ David Bould at [the University of Edinburgh](https://www.ed.ac.uk/)

It is now maintained by Mathew Topper at [Data Only Greater](
https://www.dataonlygreater.com/).

Gratitude is given to [Sandia National Labs](https://www.sandia.gov/) for their
help updating the example data. All new data was acquired from public sources.

## License

[ODbL](https://opendatacommons.org/licenses/odbl/)

[allowedits]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/allowing-changes-to-a-pull-request-branch-created-from-a-fork#enabling-repository-maintainer-permissions-on-existing-pull-requests
[topper2019reducing]: https://doi.org/10.1016/j.rser.2019.05.032
[topper2020techno]: https://doi.org/10.3390/jmse8090646
[topper2021benefits]: https://doi.org/10.1016/j.apenergy.2021.117091
