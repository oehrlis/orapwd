----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 00_config_db.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2021.11.11
--  Revision..:  
--  Purpose...: Configure database parameter
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
----------------------------------------------------------------------------
CONNECT / AS SYSDBA
ALTER SYSTEM SET db_domain='trivadislabs.com' SCOPE=spfile;
--ALTER SYSTEM SET encrypt_new_tablespaces='DDL' SCOPE=both;

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;
SELECT name, log_mode, open_mode FROM v$database;
-- EOF ---------------------------------------------------------------------