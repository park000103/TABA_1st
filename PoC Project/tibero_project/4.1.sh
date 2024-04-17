SET ECHO ON
CONN TIBERO/TMAX

#--------TABLE, DATA, INDEX--------#
CREATE TABLE PLAN_TEST(C1 NUMBER,C2 NUMBER, C3 NUMBER);

declare
begin
for i in 1..10000 loop
insert into plan_test values(i,i,i);
end loop;
end;
/

COMMIT;

CREATE INDEX PLAN_TEST_IDX ON PLAN_TEST(C1);
#--------QUERY 실행 계획 보기 및 확인--------#
SET LINES 200
SET AUTOT TRACEONLY EXP PLANSTAT
SELECT * FROM PLAN_TEST WHERE C1 BETWEEN 10 AND 100;
#--------별도 TRACE 활성화 및 확인--------#
SET AUTOT OFF
ALTER SESSION SET SQL_TRACE=Y;

SELECT * FROM PLAN_TEST WHERE C1 BETWEEN 10 AND 100;

!cd /tibero/tibero6/instance/tibero/log/sqltrace
!tbprof tb_sqltrc_1814_63_827.trc  tb_sqltrc_1814_63_827.log
!vi tb_sqltrc_1814_63_827.trc


