# The DTOcean Database

The DTOcean Database is a [PostgreSQL](https://www.postgresql.org/) database
for storing persistent data, such as ocean energy converter (OEC) designs, 
metocean observations for sites, and reference data for electrical, mooring
and foundations components, ports, vessels, etc.

The database backup stored in this repository contains free to use examples of
OECs, sites, and reference data.

## Documentation

See [dtocean.github.io](https://dtocean.github.io/) for the latest
documentation.

## Installation

A "zip" file containing the database backup and installation instructions, can 
be found on the [Releases](
https://github.com/DTOcean/dtocean-database/releases) page of this repository.

The database schema is stored in the repository as [schema.sql](
https://raw.githubusercontent.com/DTOcean/dtocean-database/master/schema.sql)

## Usage

The database is designed for use with the DTOcean suite of tools. Please go to
one of the following pages for further information:

 * [The DTOcean Installer](https://github.com/DTOcean/dtocean)
 * [dtocean-app](https://github.com/DTOcean/dtocean-app)
 * [dtocean-core](https://github.com/DTOcean/dtocean)

See the "Getting Started 2: Example Database" chapter of the [DTOcean 
documentation](https://dtocean.github.io/) for an example.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

See [this blog post](
https://www.dataonlygreater.com/latest/professional/2017/03/09/dtocean-development-change-management/)
for information regarding development of the DTOcean ecosystem.

## Credits

This database was initially created as part of the [EU DTOcean project](
https://www.dtoceanplus.eu/About-DTOceanPlus/History) by:

 * Chris O’Donoghue at [University College Cork](https://www.ucc.ie/)
 * Mathew Topper at [TECNALIA](https://www.tecnalia.com)
 * David Bould at [the University of Edinburgh](https://www.ed.ac.uk/)

It is now maintained by Mathew Topper at [Data Only Greater](
https://www.dataonlygreater.com/).

Gratitude is given to [Sandia National Labs](https://www.sandia.gov/) for their
help updating the example data. All new data was acquired from public sources.

## License

[ODbL](https://opendatacommons.org/licenses/odbl/)
