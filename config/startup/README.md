# Startup Scripts

This folder contains all files executed after the database instance is started.
Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported.

- [00_run_datapatch.sh](00_run_datapatch.sh) Script to run datapatch.
- [01_check_unified_audit.sh](01_check_unified_audit.sh) Script to check if
  unified audit is enabled.
- [99_example_setup.sql](99_example_setup.sql) Example SQL setup script.
