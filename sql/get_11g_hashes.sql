----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: hashcat.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.12.07
--  Usage.....: @hashcat
--  Purpose...: Script to dump S:/SHA1 password hashes for hashcat
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------

SET LINESIZE 160 PAGESIZE 200
COLUMN username FORMAT A30
COLUMN verifier FORMAT A60
COLUMN hash FORMAT A40
COLUMN salt FORMAT A20
SELECT
    name username,
    regexp_substr(spare4,'S\:(.+);',1,1,'i',1) verifier,
    substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 1, 40) hash,
    substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 41, 20) salt
FROM user$
WHERE spare4 IS NOT NULL 
AND substr(regexp_substr(spare4,'S\:(.+);',1,1,'i',1), 1, 40) <> '0000000000000000000000000000000000000000';
-- EOF ---------------------------------------------------------------------
