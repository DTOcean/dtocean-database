# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Calendar Versioning](https://calver.org/).

## [v2026.03.0] - 2026-03-12
### :sparkles: New Features
- [`1cbc6a6`](https://github.com/DTOcean/dtocean-database/commit/1cbc6a64444c56a96dcc14315a8171e5418c3ba8) - add database creation scripts for docker compose *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`1c0aad8`](https://github.com/DTOcean/dtocean-database/commit/1c0aad832b2db513adfb2991579f262a9a49590b) - setup dvc and add database csv files *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`482733f`](https://github.com/DTOcean/dtocean-database/commit/482733fd4fd84d8cbf08182e4f32665618491e2c) - add cloudfront distribution for public access *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`70b0ed5`](https://github.com/DTOcean/dtocean-database/commit/70b0ed5667ada8ba8f68778a728956fa9695aa5e) - add a version number to the database as a comment *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`54be684`](https://github.com/DTOcean/dtocean-database/commit/54be6848149e75bf6a460b6be5aab2d819bea14f) - added template database *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`e715c36`](https://github.com/DTOcean/dtocean-database/commit/e715c36790b1004a7ac3ac3a7581de25e53cc637) - allow localhost ports to be configured *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`55aa697`](https://github.com/DTOcean/dtocean-database/commit/55aa69702d4b08413428a8b5f6365d2434be9f31) - add tests to check database initialized correctly *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`5ecd52f`](https://github.com/DTOcean/dtocean-database/commit/5ecd52ffb5a59a98fd45e476d3e111b27e6e9ad0) - split compose files for build and runtime usage *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`c589e60`](https://github.com/DTOcean/dtocean-database/commit/c589e6092ece5354f49eaf5dc7c517cc84d15a65) - set up automated release workflow *(commit by [@H0R5E](https://github.com/H0R5E))*

### :bug: Bug Fixes
- [`925feed`](https://github.com/DTOcean/dtocean-database/commit/925feed0721f279010a74d3180caf2e0a6bda790) - added missing component data *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`6adfc2f`](https://github.com/DTOcean/dtocean-database/commit/6adfc2fafd54ca7c113eacd1ce1aa80eae859076) - apply consistent quoting in function definitions *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`485feb9`](https://github.com/DTOcean/dtocean-database/commit/485feb9378cec2a6d216b2b51ba49061d56f9320) - update dvc config for shared bucket/distribution *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`ab4ff3f`](https://github.com/DTOcean/dtocean-database/commit/ab4ff3fce2cef8f249056802de17b0a538bdf120) - fix link to dtocean documentation *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`674cb49`](https://github.com/DTOcean/dtocean-database/commit/674cb49f6fe140717c816c1661c342e3696a9464) - use fully qualified image names to support podman *(commit by [@H0R5E](https://github.com/H0R5E))*
- [`a6d567d`](https://github.com/DTOcean/dtocean-database/commit/a6d567d3613e59dbd7cd88819301f2041f06f3d6) - update installation instructions for Linux *(commit by [@H0R5E](https://github.com/H0R5E))*


## [v2.0.0] - 2019-03-12

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

## [v1.0.0] - 2016-12-19

### Added

- Initial import of database from SETIS.
- Added README, LICENSE and change log.
[v2026.03.0]: https://github.com/DTOcean/dtocean-database/compare/v2.0.0...v2026.03.0
[v2026.03.0]: https://github.com/DTOcean/dtocean-database/compare/v2.0.0...v2026.03.0
