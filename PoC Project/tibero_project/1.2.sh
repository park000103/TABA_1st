SET ECHO ON
#---------------TEST1 사용자 생성 및 권한 부여--------------#
CREATE USER TEST1 IDENTIFIED BY 'TEST1';

GRANT CONNECT, RESOURCE TO TEST1;
#---------------tbl table 생성---------------#
CREATE TABLE TEST1.TBL(ID NUMBER);

INSERT INTO TEST1.TBl VALUES(1);

COMMIT;
#---------------TEST1 사용자에 접속하고 tbl조회---------------#
CONN TEST1/TEST1

SELECT * FROM TEST1.TBL;
#---------------TEST2 사용자 생성 및 권한 부여----------------#
CONN SYS/TIBERO

CREATE USER TEST2 IDENTIFIED BY 'TEST2';

GRANT CONNECT, RESOURCE TO TEST2;
#---------------TEST2로 접속하여 TBL 조회---------------#
CONN TEST2/TEST2

SELECT * FROM TEST1.TBL;
