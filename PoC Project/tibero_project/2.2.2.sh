SET ECHO ON
#SESSION2#
#---------------TEST2 사용자로 접속---------------#
CONN TEST2/TEST2
#---------------현재 시간 확인---------------#
ALTER SESSION SET NLS_DATE_FORMAT='YYYY/MM/DD HH24:MI:SS';

SELECT SYSDATE FROM DUAL;
#--------------DATA UPDATE 전 TABLE--------------#
SELECT * FROM TEST1.MVCTEST WHERE ID=1;

