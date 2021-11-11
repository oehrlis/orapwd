----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 05_config_audit_pdb1.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2021.01.11
--  Usage.....: 
--  Purpose...: Initialize Audit trails PDB1
--  Notes.....: 
--  Reference.: 
--  License...: Apache License Version 2.0, January 2004 as shown
--              at http://www.apache.org/licenses/
----------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 160 PAGESIZE 200
ALTER SESSION SET CONTAINER=pdb1;
DECLARE
  v_version           number;
  v_datafile_path     varchar2(30);
  v_db_unique_name    varchar2(30);
  v_audit_tablespace  varchar2(30) := 'SYSAUD';
  v_audit_data_file   varchar2(513);
  e_tablespace_exists EXCEPTION;
  e_job_exists        EXCEPTION;
  e_audit_job_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_tablespace_exists,-1543);
  PRAGMA EXCEPTION_INIT(e_job_exists, -27477 );
  PRAGMA EXCEPTION_INIT(e_audit_job_exists, -46254);

BEGIN
  DBMS_OUTPUT.put_line('Setup and initialize Audit');
  SELECT regexp_substr(file_name,'^/.*/') INTO v_datafile_path FROM dba_data_files WHERE TABLESPACE_NAME='SYSTEM' and rownum <2;
  SELECT db_unique_name INTO v_db_unique_name FROM v$database;
  SELECT regexp_substr(version,'^\d+') INTO v_version FROM v$instance;

-- Datafile String for Audit Tablespace
  v_audit_data_file := v_datafile_path||lower(v_audit_tablespace)||'01'||v_db_unique_name||'.dbf'; 

-- Create Tablespace but rise an exeption if it allready exists
  DBMS_OUTPUT.put('- Create '||v_audit_tablespace||' Tablespace... ');
  BEGIN
     EXECUTE IMMEDIATE 'CREATE TABLESPACE '||v_audit_tablespace||' datafile '''||v_audit_data_file||''' size 20480K autoextend on next 10240K maxsize 1024M';
     DBMS_OUTPUT.put_line('created');
  EXCEPTION
     WHEN e_tablespace_exists THEN
          DBMS_OUTPUT.PUT_LINE('already exists');
  END;

-- Initialize Standard Audit Trail
  DBMS_OUTPUT.put_line('Start to initialize Audit Trails');
  DBMS_OUTPUT.put('- Standard Audit Trail........... ');
  IF
    NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD)
  THEN
    DBMS_AUDIT_MGMT.INIT_CLEANUP(
       audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
       default_cleanup_interval => 240 /*hours*/
    ); 
    DBMS_OUTPUT.put_line('initialized'); 
  ELSE
    DBMS_OUTPUT.put_line('skipped');
  END IF;

-- Initialize FGA Audit Trail
  DBMS_OUTPUT.put('- FGA Audit Trail................ ');
  IF
    NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD)
  THEN
    DBMS_AUDIT_MGMT.INIT_CLEANUP(
       audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
       default_cleanup_interval => 240 /*hours*/
    );
    DBMS_OUTPUT.put_line('initialized');
  ELSE
    DBMS_OUTPUT.put_line('skipped');
  END IF;

-- Initialize OS Audit Trail
  DBMS_OUTPUT.put('- OS Audit Trail................. ');
  IF
    NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS)
  THEN
    DBMS_AUDIT_MGMT.INIT_CLEANUP(
       audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
       default_cleanup_interval => 240 /*hours*/
    );
    DBMS_OUTPUT.put_line('initialized');
  ELSE
    DBMS_OUTPUT.put_line('skipped');
  END IF;

-- Initialize XML Audit Trail
  DBMS_OUTPUT.put('- XML Audit Trail................ ');
  IF
    NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML)
  THEN
    DBMS_AUDIT_MGMT.INIT_CLEANUP(
       audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
       default_cleanup_interval => 240 /*hours*/
    );
    DBMS_OUTPUT.put_line('initialized');
  ELSE
    DBMS_OUTPUT.put_line('skipped');
  END IF;

-- set location for Standard and FGA Audit Trail
  DBMS_OUTPUT.put_line('Set location to '||v_audit_tablespace||' for Standard and FGA Audit Trail');
  DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
    audit_trail_location_value => v_audit_tablespace
  );

  IF
    v_version > 11
  THEN
    DBMS_OUTPUT.put_line('Set location to '||v_audit_tablespace||' for Unified Audit');
    DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
      audit_trail_location_value => v_audit_tablespace
    );
  END IF;

-- ALL Audit Trail
  DBMS_OUTPUT.put('- ALL Audit Trail................ ');
  IF
    NOT DBMS_AUDIT_MGMT.IS_CLEANUP_INITIALIZED(DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL)
  THEN
    DBMS_AUDIT_MGMT.INIT_CLEANUP(
       audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
       default_cleanup_interval => 240 /*hours*/
    ); 
    DBMS_OUTPUT.put_line('initialized'); 
  ELSE
    DBMS_OUTPUT.put_line('skipped');
  END IF;

  DBMS_OUTPUT.put_line('Create archive timestamp jobs');
  DBMS_OUTPUT.put('- Standard Audit Trail........... ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_STD_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                     DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,LAST_ARCHIVE_TIME => sysdate-30); END;', 
      start_date => sysdate, 
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24', 
      enabled    =>  TRUE,
      comments   => 'Create an archive timestamp for standard audit'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  DBMS_OUTPUT.put('- FGA Audit Trail................ ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_FGA_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                     DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,LAST_ARCHIVE_TIME => sysdate-30); END;',
      start_date => sysdate,
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
      enabled    =>  TRUE,
      comments   => 'Create an archive timestamp for FGA audit'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  DBMS_OUTPUT.put('- OS Audit Trail................. ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_OS_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                     DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,LAST_ARCHIVE_TIME => sysdate-30); END;',
      start_date => sysdate,
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
      enabled    =>  TRUE,
      comments   => 'Create an archive timestamp for OS audit'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  DBMS_OUTPUT.put('- XML Audit Trail................ ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_XML_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                     DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,LAST_ARCHIVE_TIME => sysdate-30); END;',
      start_date => sysdate,
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
      enabled    =>  TRUE,
      comments   => 'Create an archive timestamp for XML audit'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  DBMS_OUTPUT.put('- ALL Audit Trail................ ');
  BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
      job_name   => 'DAILY_ALL_AUDIT_TIMESTAMP',
      job_type   => 'PLSQL_BLOCK',
      job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                     DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,LAST_ARCHIVE_TIME => sysdate-30); END;',
      start_date => sysdate,
      repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
      enabled    =>  TRUE,
      comments   => 'Create an archive timestamp for ALL audit'
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

-- Check if there is a unified audit trail...  
  DBMS_OUTPUT.put('- Unified Audit Trail............ ');
  IF
    v_version > 11
  THEN
    BEGIN
      DBMS_SCHEDULER.CREATE_JOB (
        job_name   => 'DAILY_UNIFIED_AUDIT_TIMESTAMP',
        job_type   => 'PLSQL_BLOCK',
        job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE => 
                       DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,LAST_ARCHIVE_TIME => sysdate-30); END;',
        start_date => sysdate,
        repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
        enabled    =>  TRUE,
        comments   => 'Create an archive timestamp for unified audit'
      );
      DBMS_OUTPUT.put_line('created');
    EXCEPTION
      WHEN e_job_exists THEN
        DBMS_OUTPUT.PUT_LINE('already exists');
    END;
  ELSE
    DBMS_OUTPUT.put_line('n/a'); 
  END IF;

-- Create daily purge job
  DBMS_OUTPUT.put_line('Create archive purge jobs');
  -- Purge Job Standard Audit Trail
  DBMS_OUTPUT.put('- Standard Audit Trail........... ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_STD_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  -- Purge Job FGA Audit Trail
  DBMS_OUTPUT.put('- FGA Audit Trail................ ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_FGA_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;
  
  -- Purge Job OS Audit Trail
  DBMS_OUTPUT.put('- OS Audit Trail................. ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_OS_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  -- Purge Job XML Audit Trail
  DBMS_OUTPUT.put('- XML Audit Trail................ ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_XML_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

  -- Purge Job Unified Audit Trail
  DBMS_OUTPUT.put('- Unified Audit Trail............ ');
  BEGIN
    DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
      audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
      audit_trail_purge_interval => 24 /* hours */,
      audit_trail_purge_name     => 'Daily_Unified_Audit_Purge_Job',
      use_last_arch_timestamp    => TRUE
    );
    DBMS_OUTPUT.put_line('created');
  EXCEPTION
    WHEN e_audit_job_exists THEN
      DBMS_OUTPUT.PUT_LINE('already exists');
  END;

END;
/

col PARAMETER_NAME FOR a30
col PARAMETER_VALUE FOR a20
col AUDIT_TRAIL FOR a20
SELECT audit_trail,parameter_name, parameter_value 
FROM dba_audit_mgmt_config_params ORDER BY audit_trail;

col JOB_NAME FOR a30
col JOB_FREQUENCY FOR a40
SELECT job_name,job_status,audit_trail,job_frequency FROM dba_audit_mgmt_cleanup_jobs;

col JOB_NAME FOR a30
col REPEAT_INTERVAL FOR a80
SELECT JOB_NAME,REPEAT_INTERVAL FROM dba_scheduler_jobs WHERE job_name LIKE '%AUDIT%' ;

col POLICY_NAME for a30
col ENTITY_NAME for a30
SELECT * FROM audit_unified_enabled_policies;

-- EOF ---------------------------------------------------------------------