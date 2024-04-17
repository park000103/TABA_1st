#--------TIBERO 재기동--------#
!tbdown
#--------TIBERO.AUDI_TEST TABLE 생성--------#
CREATE TABLE TIBERO.AUDIT_TEST(ID NUMBER);
#--------DML,DDL AUDIT 설정--------#
AUDIT insert on tibero.audit_test BY SESSION WHENEVER SUCCESSFUL;
AUDIT update on tibero.audit_test BY SESSION WHENEVER SUCCESSFUL;
AUDIT delete on tibero.audit_test BY SESSION WHENEVER SUCCESSFUL;
AUDIT create table by tibero;
INSERT INTO TIBERO.AUDIT_TEST VALUES(1);

COMMIT;
#--------TIBERO.AUDIT_TEST에 DML,DDL 쿼리 수행--------#
UPDATE TIBERO.AUDIT_TEST SET ID=2;
COMMIT;
DELETE FROM TIBERO.AUDIT_TEST;
COMMIT;
#--------AUDIT.LOG 확인--------#
!ls -al /home/tibero/audit
!vi /home/tibero/audit/audit.log
