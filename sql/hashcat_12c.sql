----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: hashhashcat_12ccat.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.12.07
--  Usage.....: @hashcat_12c
--  Purpose...: Script to dump T:/SHA512 password hashes for hashcat
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
SET HEAD OFF
SET FEEDBACK OFF
SET ECHO OFF
SET LINESIZE 180 PAGESIZE 200
SPOOL /u01/config/etc/hashes_12c.txt
COLUMN hashcat FORMAT A175
SELECT
    name ||':'||
    substr(regexp_substr(spare4,'T\:(.+)',1,1,'i',1), 1, 128) ||':'||
    substr(regexp_substr(spare4,'T\:(.+)',1,1,'i',1), 129, 32) hashcat
FROM user$
WHERE spare4 IS NOT NULL 
AND substr(regexp_substr(spare4,'T\:(.+)',1,1,'i',1), 1, 128) NOT LIKE '000000000000000000%';
SPOOL OFF
-- EOF ---------------------------------------------------------------------
