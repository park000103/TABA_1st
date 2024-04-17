SET ECHO ON
#---------------TEST 사용자 생성 및 권한 부여--------------#
CREATE USER TEST IDENTIFIED BY TEST;
GRANT CONNECT,RESOURCE TO TEST;
#---------------TEST 사용자에 접속---------------#
CONN TEST/TEST
#---------------TABLESPACE 생성후 확인-------------#
CREATE TABLESPACE TEST_PART1 DATAFILE 'TEST_PART1.DBF' SIZE 100M;
CREATE TABLESPACE TEST_PART2 DATAFILE 'TEST_PART2.DBF' SIZE 100M;
CREATE TABLESPACE TEST_PART3 DATAFILE 'TEST_PART3.DBF' SIZE 100M;
CREATE TABLESPACE TEST_PART4 DATAFILE 'TEST_PART4.DBF' SIZE 100M;

CONN SYS/TIBERO

SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;
#--------------RANGE_PART TABLE(RANGE PARTITION TABLE)-------------#
CREATE TABLE TEST.RANGE_PART
 (RANGE_NO NUMBER,
RANGE_YEAR INT NOT NULL,
RANGE_MONTH INT NOT NULL,
RANGE_DAY INT NOT NULL,
 RANGE_NAME VARCHAR2(30),
 RANGE NUMBER)
 PARTITION BY RANGE (RANGE_YEAR, RANGE_MONTH, RANGE_DAY)
 (PARTITION RANGE_Q1 VALUES LESS THAN (2005, 01, 01) TABLESPACE
TEST_PART1,
 PARTITION RANGE_Q2 VALUES LESS THAN (2005, 07, 01) TABLESPACE
TEST_PART2,
 PARTITION RANGE_Q3 VALUES LESS THAN (2006, 01, 01) TABLESPACE
TEST_PART3,
 PARTITION RANGE_Q4 VALUES LESS THAN (2006, 07, 01) TABLESPACE
TEST_PART4 );
#---------------TEST 사용자에 접속하여 DATA 입력---------------#
CONN TEST/TEST

INSERT INTO RANGE_PART VALUES(1, 2004, 06, 12, 'SCOTT', 2500);
INSERT INTO RANGE_PART VALUES(2, 2005, 06, 17, 'JONES', 4300);
INSERT INTO RANGE_PART VALUES(3, 2005, 12, 12, 'MILLER', 1200);
INSERT INTO RANGE_PART VALUES(4, 2006, 06, 22, 'FORD', 5200);
INSERT INTO RANGE_PART VALUES(5, 2005, 01, 01, 'LION', 2200);
COMMIT;

SELECT * FROM TEST.RANGE_PART;
#---------------RANGE_PART TABLE의 PARTITION TABLE 확인---------------#
COL TABLE_NAME FOR A20
COL PARTITION_NAME FOR A20
SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------NEW TABLESPACE 생성--------------#
CREATE TABLESPACE TEST_PART_MAX DATAFILE 'PART_MAX.DBF' SIZE 100M;
#---------------PARTITION TABLE 추가---------------#
ALTER TABLE RANGE_PART
ADD PARTITION RANGE_MAX VALUES LESS THAN (MAXVALUE,MAXVALUE,MAXVALUE)
TABLESPACE TEST_PART_MAX;

SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------PARTITION TABLE 삭제---------------#
ALTER TABLE RANGE_PART DROP PARTITION RANGE_MAX;

SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------PARTITION TABLE 이름 변경---------------#
ALTER TABLE RANGE_PART RENAME PARTITION RANGE_Q4 TO RANGE_FOUR;

SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------PARTITION TABLE MERGE---------------#
ALTER TABLE RANGE_PART
MERGE PARTITIONS RANGE_Q1, RANGE_Q2 INTO PARTITION RANGE_Q2
UPDATE INDEXES;

SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------PARTITION TABLE 기준에 따라 SPLIT---------------#
ALTER TABLE RANGE_PART
SPLIT PARTITION RANGE_Q2 AT (2005,01,01)
INTO (PARTITION RANGE_Q1, PARTITION RANGE_Q2);

SELECT TABLE_NAME, PARTITION_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME='RANGE_PART';
#---------------PARTITION DATA 이동을 위한 일반 TABLE 생성---------------#
CREATE TABLE RANGE_PART_EX
 (RANGE_NO NUMBER,
 RANGE_YEAR INT NOT NULL,
 RANGE_MONTH INT NOT NULL,
 RANGE_DAY INT NOT NULL,
 RANGE_NAME VARCHAR2(30),
 RANGE NUMBER)
 TABLESPACE TEST_PART1;
#---------------RANGE_Q1 DATA를 RANGE_PART_EX로 이동---------------#
ALTER TABLE RANGE_PART
EXCHANGE PARTITION RANGE_Q1
WITH TABLE RANGE_PART_EX;

SELECT RANGE_NO
FROM RANGE_PART PARTITION(RANGE_Q1);

SELECT RANGE_NO
FROM RANGE_PART_EX;
#---------------PARTITION TABLE의 TABLESPACE 변경---------------#
ALTER TABLE RANGE_PART MOVE PARTITION RANGE_Q3 TABLESPACE TEST_PART_MAX;
#---------------PARTITION TABLE TRUNCATE---------------#
ALTER TABLE RANGE_PART TRUNCATE PARTITION RANGE_Q3;

SELECT * FROM RANGE_PART PARTITION(RANGE_Q3);
