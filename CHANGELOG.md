# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
