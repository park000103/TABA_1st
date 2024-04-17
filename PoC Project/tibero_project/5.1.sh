SET ECHO ON
#--------TABLESPACE 생성--------#
CREATE TABLESPACE TS_TEST
DATAFILE 'test01.dtf' SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE 1G,
'test02.dtf' SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

CREATE TABLESPACE TS_TEST_IDX
DATAFILE 'test_idx_01.dtf' SIZE 8M AUTOEXTEND ON NEXT 8M MAXSIZE 1G EXTENT MANAGEMENT LOCAL AUTOALLOCATE;  
#--------TEST 사용자 생성 및 DBA권한 부여--------#
CREATE USER TEST IDENTIGIED BY TEST DEFAULT TABLESPACE TS_TEST;
GRANT DBA TO TEST;
CONN TEST/TEST
#--------T1 TABLE 생성--------#
CREATE TABLE TEST.T1 (ID NUMBER,
ANAME VARCHAR2(32),
BNAME VARCHAR2(32),
ID2 NUMBER)
TABLESPACE TS_TEST;
#--------T1 TABLE의 INDEX 생성--------#
CREATE INDEX IDX_T1 ON T1(ID, ANAME) TABLESPACE TS_TEST_IDX;
SELECT * FROM TEST.T1;
DESC TEST.T1;
#--------현재 존재하는 TABLESPACE DATAFILE 조회--------#
SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;
SELECT FILE_NAME FROM DBA_DATA_FILES;
#--------ONLINE BACKUP 시작--------#
ALTER DATABASE BEGIN BACKUP;

SELECT * FROM V$BACKUP;
#--------HOT BACKUP 진행(DATAFILE 복제)--------#
!ls -al /tibero/tbdata/tibero/*.dtf
!cd /tibero/tbdata/tibero
!mkdir /tibero/s/${TB_SID}_hot
!cp /tibero/tbdata/tibero/*.dtf   /tibero/s/tibero_hot/.
!ls -al /tibero/s/tibero_hot

#--------ONLINE BACKUP 끝냄--------#
ALTER DATABASE END BACKUP;
#--------현재 BACKUP중인 DATAFILE확인--------#
SELECT * FROM V$BACKUP;
#--------LOG SWITCH 수행--------#
ALTER SYSTEM SWITCH LOGFILE;
#--------T1 TABLE에 DATA 입력--------#
INSERT INTO TEST.T1
SELECT ROWNUM,
'A'||TO_CHAR(ROWNUM),
'B'||TO_CHAR(ROWNUM),
ROUND(ROWNUM/50)
FROM DUAL CONNECT BY ROWNUM<=50000;

COMMIT;

SELECT COUNT(*) FROM TEST.T1;

#----------DATAFILE 삭제----------#
!rm /tibero/tbdata/tibero/*.dtf
!ls /tibero/tbdata/tibero
!ls /tibero/s/tibero_hot
#--------TIBERO 기동하여 장애 확인--------#
!tbboot
#--------BACK UP 원복--------#
!cp -r /tibero/tbdata/tibero/tibero_hot/*.dtf  /tibero/tbdata/tibero/.
!ls -al /tibero/tbdata/tibero
#--------TIBERO MOUNT모드 기동--------#
!tbboot mount

#--------복구 수행--------#
ALTER DATABASE RECOVER AUTOMATIC;

#-------TIBERO 종료 및 TIBERO 기동--------#
!tbdown
!tbboot

#--------TABLE 건수 조회--------#
SELECT COUNT(*) FROM TEST.T1;

QUIT
