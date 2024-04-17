SET ECHO ON
#--------복구 관리자를 통해 ONLINE FULL BACKUP--------#
!export TB_BACKUP=/home/tibero/backup
!mkdir -p $TB_BACKUP/full
!tbrmgr backup -o $TB_BACKUP/full -v

#---------t1 건수 조회--------#
SELECT COUNT(*) FROM TEST.T1;
#--------DATA 입력--------#
INSERT INTO TEST.T1
 SELECT ROWNUM ,
 'A'||TO_CHAR(ROWNUM),
 'B'||TO_CHAR(ROWNUM),
 ROUND(ROWNUM/50)
 FROM DUAL CONNECT BY ROWNUM<=50000;

COMMIT;

SELECT COUNT(*) FROM TEST.T1;

#--------Incremental Backup 1--------#
!cp -r $TB_BACKUP/full  $TB_BACKUP/incremental
!tbrmgr backup -o $TB_BACKUP/incremental -i -v

#--------DATA 입력 및 건수 조회--------#
INSERT INTO TEST.T1
 SELECT ROWNUM ,
 'A'||TO_CHAR(ROWNUM),
 'B'||TO_CHAR(ROWNUM),
 ROUND(ROWNUM/50)
 FROM DUAL CONNECT BY ROWNUM<=50000;

COMMIT;

SELECT COUNT(*) FROM TEST.T1;

#--------Incremental Backup 2--------#
!tbrmgr backup -o $TB_BACKUP/incremental -i -v

#--------DATA 입력 및 건수 조회--------#
INSERT INTO TEST.T1
 SELECT ROWNUM ,
 'A'||TO_CHAR(ROWNUM),
 'B'||TO_CHAR(ROWNUM),
 ROUND(ROWNUM/50)
 FROM DUAL CONNECT BY ROWNUM<=50000;

COMMIT;

SELECT COUNT(*) FROM TEST.T1;

#--------Incremental Backup 3--------#
!tbrmgr backup -o $TB_BACKUP/incremental -i -v
!ls -al $TB_BACKUP/incremental

#--------TIBERO 종료 및 DATAFILE 삭제--------#
!tbdown
!rm /tibero/tbdata/tibero/*.dtf
#--------TIBERO 기동하여MOUNT모드 및 장애 상황 확인 후 다시 종료--------#
!tbboot
!tbdown immediate
#--------tbrmgr recovery--------#
!tbrmgr recover -o $TB_BACKUP/incremental -v

SELECT COUNT(*) FROM TEST.T1;

