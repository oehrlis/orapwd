----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: verify_user_password_no.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.12.11
--  Revision..:  
--  Purpose...: Wrapper script to check if a user in sys.user$  
--              has a weak password. Passwords will not be displayed
--  Usage.....: @verify_user_password_no
--  Notes.....: 
--  Reference.: requires execute on dbms_crypto
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
@verify_passwords.sql FALSE &1 60
-- EOF ---------------------------------------------------------------------