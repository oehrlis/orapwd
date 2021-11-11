# Setup Scripts

This folder contains all files executed after the database instance is initially
created. Currently only bash scripts (.sh) as well SQL scripts (.sql) are supported.

- [00_config_db.sql](00_config_db.sql) Script to configure the DB e.g init
  parameter and more.
- [01_enable_unified_audit.sh](01_enable_unified_audit.sh) Script to enable
  unified audit.
- [01_run_datapatch.sh](01_run_datapatch.sh) Script to run the datapatch and install
  release updates.
- [02_create_scott_pdb1.sql](02_create_scott_pdb1.sql) Script to create the
  *SCOTT* schema.
- [03_create_tvd_hr_pdb1.sql](03_create_tvd_hr_pdb1.sql) Main script to create
  the *TVD_HR* schema in PDB1.
- [04_config_audit_cdb.sql](04_config_audit_cdb.sql) Script to configure unified
  audit for CDB.
- [04_config_audit_pdb1.sql](04_config_audit_pdb1.sql) Script to configure unified
  audit for PDB1.
- [05_clone_pdb1_pdb2.sql](05_clone_pdb1_pdb2.sql) Script to clone PDB1 to PDB2.
