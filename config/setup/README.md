# Setup Scripts

This folder contains all files executed after the database instance is initially created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported.

- [00_switch_off_archive_mode.sql](00_switch_off_archive_mode.sql) Script to disable ARCHIVELOG MODE.
- [01_create_scott.sql](01_create_scott.sql) Wrapper script for ``utlsampl.sql`` to create the SCOTT schema.
- [02_create_tvd_hr.sql](02_create_tvd_hr.sql) Script to create the TVD_HR schema. TVD_HR schema corresponds to Oracle's standard HR schema. The data has been adjusted so that it matches the example LDAP data of *trivadislabs.com*.
- [99_example_setup.sh](99_example_setup.sh) Example setup script.