# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2026.01.0] - 2026-01-20

### Fixed

- Fixed inconsistent quoting in function definitions

## [2025.04.0] - 2025-04-08

### Added

- Add functions to dump and load database tables to and from csv files
- Add docker compose files for setting up postgres/postgis, initiating dtocean
  databases, and setting up pgadmin
- Added Poetry configuration for managing Python dependencies
- Use [DVC](https://dvc.org/) for putting database tables under version control
- Add JSON metadata to database comment to allow checking of the schema version
- Add GA workflow to test that container successfully starts and is initialized
  correctly
- Add GA workflow for packaging database releases by downloading data using
  DVC, creating an .env file with the version number and copying required files
  to a dist folder from which archives are created.
- Add Python based tests to check database initialization
- Add dedicated installation instructions in INSTALLATION.md file

### Changed

- Replace basic tidal example with Takoma Narrows data
- Update README to reflect changes

## [2.0.0] - 2019-03-12

### Added

- Added stored procedures to help rebuild "filter" and "reference" schemas on
  table modification (sp_drop_views, sp_build_tables, sp_build_views).
- Added new wave device (RM3).
- Added new wave energy extraction site (Eureka, Ca.).

### Changed

- Split the single "beta" schema into three: "filter", "project" and
  "reference". The "project" schema contains sites and devices and the
  "reference" scheme contains reference data. The "filter" schema is populated
  automatically by the filtering stored procedures. Potentially, a "filter"
  schema could be provided per user, to allow multiple user access.
- Updated component reliability reference data.
- Updated port reference data.

### Removed

- Removed columns which were unused by the DTOcean software.
- Removed original dummy wave energy device and site examples.

## [1.0.0] - 2016-12-19

### Added

- Initial import of database from SETIS.
- Added README, LICENSE and change log.
