----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 05_clone_pdb1_pdb2.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Revision..:  
--  Purpose...: Script to clone PDB1 to PDB2
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- set the current
--ALTER PLUGGABLE DATABASE pdb1 CLOSE;
COLUMN cdb_path NEW_VALUE cdb_path NOPRINT
SELECT TRIM(TRAILING '/' FROM substr(file_name, 1, instr(file_name, '/', -1, 1))) cdb_path FROM dba_data_files WHERE file_id=1;

CREATE PLUGGABLE DATABASE pdb2 FROM pdb1
  FILE_NAME_CONVERT=('&cdb_path/PDB1/','&cdb_path/PDB2/');

--ALTER PLUGGABLE DATABASE pdb1 OPEN READ WRITE;
ALTER PLUGGABLE DATABASE pdb2 OPEN READ WRITE;

--ALTER PLUGGABLE DATABASE pdb1 SAVE STATE;
ALTER PLUGGABLE DATABASE pdb2 SAVE STATE;
-- EOF ---------------------------------------------------------------------