libname final "D:\RRD\final";
libname sas "D:\RRD\sas";
libname sas_re "D:\RRD\sas_re";

/* 1. �Ȱ� �湮 ���� - T30���� �з��ڵ� DIV_CD = 'E6810', 'EY791', 'EY792', 'EY799' ���ص����̰�˻��� KEY_SEQ ã�� */
/* OBS = 6,145,074 */
proc sql;
create table sas_re.t30_1 as 
select *
from final.t30
where DIV_CD in ('E6810', 'EY791', 'EY792', 'EY799')
; quit;

proc sql;
select count(*) as N_obs
from sas_re.t30_1;
run; quit;

/*2. t20�� PERSON_ID�� t30 ���ص����̰�˻��� KEY_SEQ join*/
/* ID = 833,740 *//* OBS = 6,145,074 */
proc sql;
create table sas_re.id_seq as
select *
from final.t20 as t20
inner join sas_re.t30_1 as t30
on t20.KEY_SEQ = t30.KEY_SEQ
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.id_seq;
run; quit;

/*t20-t30 ����*/
/* ID = 1,113,253 *//* OBS = 576,969,968 */
proc sql;
create table sas_re.all_id_seq as
select *
from final.t20 as t20
inner join final.t30 as t30
on t20.KEY_SEQ = t30.KEY_SEQ
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.all_id_seq;
run; quit;

/*3. �ش� PERSON_ID�� t30 ��� KEY_SEQ ��������*/
/* ID = 833,740 *//* OBS = 489,440,000 */
proc sql;
create table sas_re.op_visitors as
select * from sas_re.all_id_seq
where all_id_seq.PERSON_ID in (select distinct(PERSON_ID) from sas_re.id_seq)
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.op_visitors;
run; quit;

proc sort data=sas_re.op_visitors;
by PERSON_ID RECU_FR_DT;
run;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/* ���ܴ���� */
/* ID = 38,183 *//* OBS = 1,780,159 */

proc sql;
create table sas_re.exclude as 
select *
from sas_re.op_visitors
where substr(MAIN_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') 
or substr(SUB_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') 
or substr(MAIN_SICK,1,3) between 'Q00' and 'Q99' or substr(SUB_SICK,1,3) between 'Q00' and 'Q99' 
order by PERSON_ID, RECU_FR_DT
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.exclude;
run;
quit;

proc sql;
select count(case when substr(MAIN_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') then 1 end) as cnt_main,
          count(case when substr(SUB_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') then 1 end) as cnt_sub,
		  count(case when substr(MAIN_SICK,1,3) between 'Q00' and 'Q99' or substr(SUB_SICK,1,3) between 'Q00' and 'Q99' then 1 end) as cnt_q,
		  count(*) as cnt_all
from sas_re.exclude;
run; quit;

/*���ܴ��������*//*id �������� ���ŵ�*/
/* ID = 795,557 *//* OBS = 461,040,000 */
proc sql;
create table sas_re.cohort as
select * from sas_re.op_visitors
where op_visitors.PERSON_ID not in (select distinct(PERSON_ID) from sas_re.exclude)
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.cohort;
run;
quit;

proc sql;
select count(case when substr(MAIN_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') then 1 end) as cnt_main,
          count(case when substr(SUB_SICK,1,4) in ('H440', 'H441', 'H451', 'H446', 'H447', 'H320', 'A185', 'B580', 'A527', 'B258', 'S021', 'S023', 'S028', 'S052', 'S053', 'S054', 'S055', 'S056') then 1 end) as cnt_sub,
		  count(case when substr(MAIN_SICK,1,3) between 'Q00' and 'Q99' or substr(SUB_SICK,1,3) between 'Q00' and 'Q99' then 1 end) as cnt_q,
		  count(*) as cnt_all
from sas_re.cohort;
run; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*
< �ʿ亯�� >
PERSON_ID �����Ϸù�ȣ t20
KEY_SEQ û���Ϸù�ȣ t20, t30
SEQ_NO �Ϸù�ȣ t30
RECU_FR_DT ��簳������  t20, t30
DSBJT_CD ��������ڵ�(����,�Ű��,�Ȱ�,�̺����İ���)  t20
MAIN_SICK �ֻ� ICD-10 �ڵ�  t20
SUB_SICK �λ� ICD-10 �ڵ� t20
DIV_CD �з��ڵ� EDI �ڵ�  t30
TOT_PRES_DD_CNT ��ó���ϼ�  t20
MDCN_EXEC_FREQ �������ϼ��Ǵ½ǽ�Ƚ��  t30
MPRSC_GRANT_NO ó�����������ĺ���ü��ȣ  t20
YKIHO_ID ������ĺ���ü��ȣ  t20
*/

/*�ʿ亯�� ����*/
/* ID = 795,557 *//* OBS = 461,040,000 */
proc contents data=sas_re.cohort position;
run;

data sas_re.cohort_need;
retain PERSON_ID KEY_SEQ SEQ_NO RECU_FR_DT DSBJT_CD MAIN_SICK SUB_SICK DIV_CD TOT_PRES_DD_CNT MDCN_EXEC_FREQ MPRSC_GRANT_NO YKIHO_ID;
set sas_re.cohort (keep=PERSON_ID KEY_SEQ SEQ_NO RECU_FR_DT DSBJT_CD MAIN_SICK SUB_SICK DIV_CD TOT_PRES_DD_CNT MDCN_EXEC_FREQ MPRSC_GRANT_NO YKIHO_ID);
run;

proc sort data=sas_re.cohort_need;
by PERSON_ID RECU_FR_DT;
run;

/*�Ȱ��湮��� ��������ڵ� DSBJT_CD = '12' �Ȱ�*/
/* ID = 783,699 *//* OBS = 25,047,648 *//*DSBJT_CD in ('12')*/
/* ID = 795,557 *//* OBS = 25,274,520 *//*DSBJT_CD in ('12') or DIV_CD in ('E6810', 'EY791', 'EY792', 'EY799')*/
proc sql;
create table sas_re.op_cohort as 
select *
from sas_re.cohort_need
where DSBJT_CD in ('12') or DIV_CD in ('E6810', 'EY791', 'EY792', 'EY799')
order by PERSON_ID, RECU_FR_DT
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.op_cohort;
run;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*RECU_FR_DT ��簳���� char -> date*/
/* ID = 795,557 *//* OBS = 25,274,520 */
data test;
    format test yymmddn8.;
    test=today();
    put test=;
run;

data datechange;
set sas_re.op_cohort;
RECU_FR_DT_D = input(substr(RECU_FR_DT,1,8), yymmdd8.);
format RECU_FR_DT_D yymmddn8.;
run;

data sas_re.op_cohort_date;
retain PERSON_ID KEY_SEQ SEQ_NO RECU_FR_DT_D DSBJT_CD MAIN_SICK SUB_SICK DIV_CD TOT_PRES_DD_CNT MDCN_EXEC_FREQ MPRSC_GRANT_NO YKIHO_ID;
set datechange (keep=PERSON_ID KEY_SEQ SEQ_NO RECU_FR_DT_D DSBJT_CD MAIN_SICK SUB_SICK DIV_CD TOT_PRES_DD_CNT MDCN_EXEC_FREQ MPRSC_GRANT_NO YKIHO_ID);
rename RECU_FR_DT_D = RECU_FR_DT;
run;

/*Entry Date �����*/
/* ID = 795,557 *//* OBS = 25,274,520 */
proc sql;
create table sas_re.op_cohort_entrydate as
select *, min(RECU_FR_DT) format= yymmddn8. as ENTRY_DATE	
from sas_re.op_cohort_date
group by PERSON_ID
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
create table sas_re.op_cohort_final as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, DSBJT_CD, MAIN_SICK, SUB_SICK, DIV_CD, TOT_PRES_DD_CNT, MDCN_EXEC_FREQ, MPRSC_GRANT_NO, YKIHO_ID
from sas_re.op_cohort_entrydate
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*RRD ���� ���̽� PERSON_ID ����*/
/* ID = 2,092 *//* OBS = 128,472 */
proc sql;
create table sas_re.case_id as 
select *
from sas_re.op_cohort_final
where substr(MAIN_SICK,1,4) in ('H330', 'H335') or substr(SUB_SICK,1,4) in ('H330', 'H335') 
and DIV_CD in ('S5130', 'S5121')
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_id;
run;
quit;

/*RRD ���� ���̽� ���� �����  PERSON_ID ����*/
/* ID = 2,372 *//* OBS = 64,163 */
proc sql;
create table sas_re.case_id_exclude as 
select *
from sas_re.op_cohort_final
where substr(MAIN_SICK,1,4) in ('H334', 'H332') or substr(SUB_SICK,1,4) in ('H334', 'H332') or DIV_CD in ('S5122')
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_id_exclude;
run;
quit;

/*RRD ���� ���̽� ���� ����� ������ �� PERSON_ID*/
/* ID = 1,665 *//* OBS = 90,084 */
proc sql;
create table sas_re.case_id_final as
select * from sas_re.case_id
where case_id.PERSON_ID not in (select distinct(PERSON_ID) from sas_re.case_id_exclude)
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_id_final;
run;
quit;

proc sql;
select count(case when substr(MAIN_SICK,1,4) in ('H330', 'H335') or substr(SUB_SICK,1,4) in ('H330', 'H335')  then 1 end) as cnt_yes,
          count(case when substr(MAIN_SICK,1,4) in ('H334', 'H332')  then 1 end) as cnt_no_main,
		  count(case when substr(SUB_SICK,1,4) in ('H334', 'H332')  then 1 end) as cnt_no_sub,
		  count(*) as cnt_all
from sas_re.case_id_final;
run; quit;

/*RRD ���� ���̽� ID�� ��ü OBS ��������*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.case_final as
select * from sas_re.op_cohort_final
where op_cohort_final.PERSON_ID in (select distinct(PERSON_ID) from sas_re.case_id_final)
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_final;
run; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/* DIV_CD ('S5130', 'S5121') ���� ���� */
/* ID = 699 *//* SURGERY = 881*//* OBS = 267,912 */
/*
proc sql;
select count(case when DIV_CD in ('S5130', 'S5121')  then 1 end) as cnt_surgery,
		  count(*) as cnt_all
from sas_re.case_final;
run; quit;

proc sql;
create table surgery as
select *
from sas_re.case_final
where DIV_CD in ('S5130', 'S5121')
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from surgery;
run; quit;
*/
/*RECU_FR_DT = ENTRY_DATE�� DIV_CD ('S5130', 'S5121') �������� 
MAIN_SICK ('H330', 'H335') SUB_SICK ('H330', 'H335') RD ����*/
/*
proc sql;
create table exclude as 
select *
from sas_re.case_final
where RECU_FR_DT = ENTRY_DATE 
and substr(MAIN_SICK,1,4) in ('H334', 'H332') or substr(SUB_SICK,1,4) in ('H334', 'H332')
and DIV_CD not in ('S5122')
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;
*/

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Index Date �����*/
/*RRD ���� ���̽� ID�� ��ü OBS ��������*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.indexdate as
select *, 
case when substr(MAIN_SICK,1,4) in ('H330', 'H335') or substr(SUB_SICK,1,4) in ('H330', 'H335') and DIV_CD in ('S5130', 'S5121')
then RECU_FR_DT end as INDEX_DATE format=yymmddn8.
from sas_re.case_final
group by PERSON_ID
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.indexdate;
run; quit;

proc sql;
create table sas_re.indexdate_order as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, INDEX_DATE, DSBJT_CD, MAIN_SICK, SUB_SICK, DIV_CD, TOT_PRES_DD_CNT, MDCN_EXEC_FREQ, MPRSC_GRANT_NO, YKIHO_ID
from sas_re.indexdate
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

/*�ٽ�*/
/*Index Date �����*/
/*RRD ���� ���̽� ���� ����� ������ �� PERSON_ID*/
/* ID = 1,665 *//* OBS = 90,084 */
proc sql;
create table sas_re.indexdate_re as
select *, min(RECU_FR_DT) format= yymmddn8. as INDEX_DATE	
from sas_re.case_id_final
group by PERSON_ID
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
create table sas_re.indexdate_final as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, INDEX_DATE, DSBJT_CD, MAIN_SICK, SUB_SICK, DIV_CD, TOT_PRES_DD_CNT, MDCN_EXEC_FREQ, MPRSC_GRANT_NO, YKIHO_ID
from sas_re.indexdate_re
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.indexdate_final;
run; quit;

/*ID�� INDEX_DATE ���̺�*/
proc sql;
create table sas_re.id_indexdate as
select distinct PERSON_ID, INDEX_DATE
from sas_re.indexdate_final
order by PERSON_ID
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.id_indexdate;
run; quit;

/*RRD ���� ���̽� ID�� ��ü OBS�� INDEX_DATE ���̺� �̳�����*/
/*RRD ���� ���̽� ID�� ��ü OBS �� �̳�����*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.case_final_indexdate as
select cs.PERSON_ID, cs.KEY_SEQ, cs.SEQ_NO, cs.RECU_FR_DT, cs.ENTRY_DATE, ind.INDEX_DATE, cs.DSBJT_CD, cs.MAIN_SICK, cs.SUB_SICK, cs.DIV_CD, cs.TOT_PRES_DD_CNT, cs.MDCN_EXEC_FREQ, cs.MPRSC_GRANT_NO, cs.YKIHO_ID 
from sas_re.case_final as cs
inner join sas_re.id_indexdate as ind
on cs.PERSON_ID = ind.PERSON_ID
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_final_indexdate;
run; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Confounding Factors �������� */
/*Keratoplasty ���������� S5372*/
proc sql;
select count(case when DIV_CD in ('S5372')  then 1 end) as cnt_kera
from sas_re.case_final_indexdate;
run; quit;

proc sql;
create table test as
select *,
	case
		when ( DIV_CD in ('S5372') ) then 1
		else 0
	end as KERAT
from sas_re.case_final_indexdate;
run; quit;

proc sql;
select count(case when KERAT = 1  then 1 end) as cnt_kera
from  test ;
run; quit;

/*Confounding Factors ��������*/
/*��ü Comorbidities ���ݻ�*/
/*
Cataract surgery �鳻�� ���� 'S5119', 'S5111', 'S5117'
Glaucoma surgery �쳻����� 'S5042', 'S5049'
Keratoplasty ���������� 'S5372'
Vitrectomy ����ü������ 'S5121'
Diabetes �索�� 'E10' - 'E14', 'H360'
Degenerative myopia ���༺ �ٽ� 'H442'
*/
proc sql;
create table sas_re.case_conf as
select *,
	case
		when ( DIV_CD in ('S5119', 'S5111', 'S5117') ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( DIV_CD in ('S5042', 'S5049') ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( DIV_CD in ('S5372') ) then 1
		else 0
	end as KERAT,
	case
		when ( DIV_CD in ('S5121') ) then 1
		else 0
	end as VITR,
	case
		when (substr(MAIN_SICK,1,3) between 'E10' and 'E14' or substr(SUB_SICK,1,3) between 'E10' and 'E14'
			  or substr(MAIN_SICK,1,4) in ('H360') or substr(SUB_SICK,1,4) in ('H360')) then 1
		else 0
	end as DIAB,
	case
		when (substr(MAIN_SICK,1,4) in ('H442') or substr(SUB_SICK,1,4) in ('H442')) then 1
		else 0
	end as DEG_MYO
from sas_re.case_final_indexdate
;run; quit;

proc sql;
create table count_id as
select *
from sas_re.case_conf 
where DIAB = 1
;run; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from count_id;
run; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_conf;
run; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Case Final Indexdate ���̺� �ڰ� DB ���� �߰�*/
/*�ڰ�DB - SEX �� / STND_Y ���س⵵ / AGE_GROUP ���س⵵ ���� / SIDO �õ��ڵ�/ SGG �ñ��� / CTRB_PT_TYPE_CD �����ҵ���� �߰�*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sort data=final.jk;
by PERSON_ID STND_Y;
run;

/*datechange test*/
data datechange;
set sas_re.id_indexdate;
YYYY = put(INDEX_DATE, year4.);
format YYYY $4.;
run;

/*work library�� �ӽ� datechange ����*/
data case_final_indexdate;
set sas_re.case_final_indexdate;
YYYY = put(RECU_FR_DT, year4.);
format YYYY $4.;
run;

/*STND_Y�� AGE_GROUP ���̱�*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.case_jk as
select cn.PERSON_ID, cn.KEY_SEQ, cn.SEQ_NO, cn.RECU_FR_DT, cn.ENTRY_DATE, cn.INDEX_DATE, cn.DSBJT_CD, cn.MAIN_SICK, cn.SUB_SICK,  cn.DIV_CD, cn.TOT_PRES_DD_CNT, cn.MDCN_EXEC_FREQ, cn.MPRSC_GRANT_NO, cn.YKIHO_ID,
jk.SEX, jk.STND_Y, jk.AGE_GROUP, jk.SIDO, jk.SGG, jk.CTRB_PT_TYPE_CD
from case_final_indexdate as cn
inner join final.jk as jk
on cn.PERSON_ID = jk.PERSON_ID
where cn.YYYY = jk.STND_Y
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_jk;
run;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Final Case ��*/
/*Confounding Factors ��������+�ڰ�DB*/
/*Case*//* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.final_case as
select cj.PERSON_ID, cj.KEY_SEQ, cj.SEQ_NO, cj.RECU_FR_DT, cj.ENTRY_DATE, cj.INDEX_DATE, cj.DSBJT_CD, cj.MAIN_SICK, cj.SUB_SICK,  cj.DIV_CD, cj.TOT_PRES_DD_CNT, cj.MDCN_EXEC_FREQ, cj.MPRSC_GRANT_NO, cj.YKIHO_ID,
cj.SEX, cj.STND_Y, cj.AGE_GROUP, cj.SIDO, cj.SGG, cj.CTRB_PT_TYPE_CD, cf.CAT_SUR, cf.GLAU_SUR, cf.KERAT, cf.VITR, cf.DIAB, cf.DEG_MYO
from sas_re.case_jk as cj
inner join sas_re.case_conf as cf
on cj.PERSON_ID = cf.PERSON_ID
where cj.KEY_SEQ = cf.KEY_SEQ and cj.SEQ_NO = cf.SEQ_NO
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_case;
run;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Control ��*/
/*RRD ���� ���̽� ���� PERSON_ID ����*/
/*Cohort*//* ID = 795,557 *//* OBS = 25,274,520 */
/*Case*//* ID = 1,665 *//* OBS = 267,912 */
/*Control*//* ID = 793,892 *//* OBS = 25,006,608*/
proc sql;
create table sas_re.control_final as
select * from sas_re.op_cohort_final
where op_cohort_final.PERSON_ID not in (select distinct(PERSON_ID) from sas_re.case_id_final)
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.control_final;
run; quit;

/*Confounding Factors ��������*/
/*��ü Comorbidities ���ݻ�*/
/*
Cataract surgery �鳻�� ���� 'S5119', 'S5111', 'S5117'
Glaucoma surgery �쳻����� 'S5042', 'S5049'
Keratoplasty ���������� 'S5372'
Vitrectomy ����ü������ 'S5121'
Diabetes �索�� 'E10' - 'E14', 'H360'
Degenerative myopia ���༺ �ٽ� 'H442'
*/
proc sql;
create table sas_re.control_conf as
select *,
	case
		when ( DIV_CD in ('S5119', 'S5111', 'S5117') ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( DIV_CD in ('S5042', 'S5049') ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( DIV_CD in ('S5372') ) then 1
		else 0
	end as KERAT,
	case
		when ( DIV_CD in ('S5121') ) then 1
		else 0
	end as VITR,
	case
		when (substr(MAIN_SICK,1,3) between 'E10' and 'E14' or substr(SUB_SICK,1,3) between 'E10' and 'E14'
			  or substr(MAIN_SICK,1,4) in ('H360') or substr(SUB_SICK,1,4) in ('H360')) then 1
		else 0
	end as DIAB,
	case
		when (substr(MAIN_SICK,1,4) in ('H442') or substr(SUB_SICK,1,4) in ('H442')) then 1
		else 0
	end as DEG_MYO
from sas_re.control_final
;run; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.control_conf;
run; quit;

/*Control Final ���̺� �ڰ� DB ���� �߰�*/
/*�ڰ�DB - SEX �� / STND_Y ���س⵵ / AGE_GROUP ���س⵵ ���� / SIDO �õ��ڵ�/ SGG �ñ��� / CTRB_PT_TYPE_CD �����ҵ���� �߰�*/
/*Control*//* ID = 793,892 *//* OBS = 25,006,608*/

/*work library�� �ӽ� datechange ����*/
data control_final;
set sas_re.control_final;
YYYY = put(RECU_FR_DT, year4.);
format YYYY $4.;
run;

/*STND_Y�� AGE_GROUP ���̱�*/
/* ID = 1,665 *//* OBS = 267,912 */
proc sql;
create table sas_re.control_jk as
select cn.PERSON_ID, cn.KEY_SEQ, cn.SEQ_NO, cn.RECU_FR_DT, cn.ENTRY_DATE, cn.DSBJT_CD, cn.MAIN_SICK, cn.SUB_SICK,  cn.DIV_CD, cn.TOT_PRES_DD_CNT, cn.MDCN_EXEC_FREQ, cn.MPRSC_GRANT_NO, cn.YKIHO_ID,
jk.SEX, jk.STND_Y, jk.AGE_GROUP, jk.SIDO, jk.SGG, jk.CTRB_PT_TYPE_CD
from control_final as cn
inner join final.jk as jk
on cn.PERSON_ID = jk.PERSON_ID
where cn.YYYY = jk.STND_Y
order by PERSON_ID, RECU_FR_DT, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.control_jk;
run;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Final Control ��*/
/*Confounding Factors ��������+�ڰ�DB*/
/*Control*//* ID = 793,892 *//* OBS = 25,006,608*/
proc sql;
create table sas_re.final_control as
select cj.PERSON_ID, cj.KEY_SEQ, cj.SEQ_NO, cj.RECU_FR_DT, cj.ENTRY_DATE, cj.DSBJT_CD, cj.MAIN_SICK, cj.SUB_SICK,  cj.DIV_CD, cj.TOT_PRES_DD_CNT, cj.MDCN_EXEC_FREQ, cj.MPRSC_GRANT_NO, cj.YKIHO_ID,
cj.SEX, cj.STND_Y, cj.AGE_GROUP, cj.SIDO, cj.SGG, cj.CTRB_PT_TYPE_CD, cf.CAT_SUR, cf.GLAU_SUR, cf.KERAT, cf.VITR, cf.DIAB, cf.DEG_MYO
from sas_re.control_jk as cj
inner join sas_re.control_conf as cf
on cj.PERSON_ID = cf.PERSON_ID
where cj.KEY_SEQ = cf.KEY_SEQ and cj.SEQ_NO = cf.SEQ_NO
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_control;
run;
quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*work library���� �۾��� matching final ���̺� ID�� ��ȣƮ ��������*/
/*case_id = 1,345��*//*control_id = 13,450��*//*��ü obs = 13,450*/

/*Case Final (w/ confounders and �ڰ�DB)*/
proc sql;
create table sas_re.final_case_matching as
select * 
from sas_re.final_case
where final_case.PERSON_ID in (select distinct(case_id) from sas_re.matching_final)
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

/*���� case = 1,665��*//*��Ī case = 1,345��*/
/*OBS 267,912�� -> 221,769��*/
proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_case;
run; quit;
proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_case_matching;
run; quit;

/*Control Final (w/ confounders and �ڰ�DB)*/
proc sql;
create table sas_re.final_control_matching as
select * from sas_re.final_control
where final_control.PERSON_ID in (select distinct(control_id) from sas_re.matching_final)
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

/*���� control = 793,892��*//*��Ī control = 13,450��*/
/*OBS 25,006,608�� -> 678,828��*/
proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_control;
run; quit;
proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.final_control_matching;
run; quit;

/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*control ���̺� index_date = null ó��*/
data final_control_matching;
set sas_re.final_control_matching;
format INDEX_DATE yymmddn8.;
run;

proc sql;
create table sas_re.final_control_matching_indexdate as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, INDEX_DATE, DSBJT_CD, MAIN_SICK, SUB_SICK,  DIV_CD, TOT_PRES_DD_CNT, MDCN_EXEC_FREQ, MPRSC_GRANT_NO, YKIHO_ID,
SEX, STND_Y, AGE_GROUP, SIDO, SGG, CTRB_PT_TYPE_CD, CAT_SUR, GLAU_SUR, KERAT, VITR, DIAB, DEG_MYO
from final_control_matching
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

/*case�� control�� union*/
proc sql;
create table sas_re.case_control_union as
select *, 1 as RRD from sas_re.final_case_matching
union
select *, 0 as RRD from sas_re.final_control_matching_indexdate 
; quit;

proc sql;
select count(distinct person_id) as N_id,
		  count(*) as N_obs
from sas_re.case_control_union;
run; quit;

proc sql;
select count(case when RRD = 1 then 1 end) as cnt_case
from sas_re.case_control_union
; quit;

proc means data=sas_re.case_control_union;
class RRD;
var PERSON_ID;
run;


/*------------------------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Case Representative ID*/
proc sort data=sas_re.final_case_matching nodupkey;
by PERSON_ID;
run;

proc sql;
create table case_a1 as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, INDEX_DATE,
SEX, STND_Y, AGE_GROUP, SIDO, SGG, CTRB_PT_TYPE_CD
from sas_re.final_case_matching
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

proc sql;
create table case_can as
select *,
	case
		when ( DIV_CD in ('S5119', 'S5111', 'S5117') ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( DIV_CD in ('S5042', 'S5049') ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( DIV_CD in ('S5372') ) then 1
		else 0
	end as KERAT,
	case
		when ( DIV_CD in ('S5121') ) then 1
		else 0
	end as VITR,
	case
		when (substr(MAIN_SICK,1,3) between 'E10' and 'E14' or substr(SUB_SICK,1,3) between 'E10' and 'E14'
			  or substr(MAIN_SICK,1,4) in ('H360') or substr(SUB_SICK,1,4) in ('H360')) then 1
		else 0
	end as DIAB,
	case
		when (substr(MAIN_SICK,1,4) in ('H442') or substr(SUB_SICK,1,4) in ('H442')) then 1
		else 0
	end as DEG_MYO
from sas_re.case_final_indexdate
;run; quit;

proc sql;
create table case_a2 as
select *,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where CAT_SUR = 1) ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where GLAU_SUR = 1) ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where KERAT = 1) ) then 1
		else 0
	end as KERAT,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where VITR = 1) ) then 1
		else 0
	end as VITR,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where DIAB = 1) ) then 1
		else 0
	end as DIAB,
	case
		when ( PERSON_ID in (select PERSON_ID from case_can where DEG_MYO = 1) ) then 1
		else 0
	end as DEG_MYO
from case_a1
;run; quit;

data sas_re.case_done;
set case_a2;
run;

/*Control Representative ID*/
proc sort data=sas_re.final_control_matching_indexdate nodupkey;
by PERSON_ID;
run;

proc sql;
create table control_a1 as
select PERSON_ID, KEY_SEQ, SEQ_NO, RECU_FR_DT, ENTRY_DATE, INDEX_DATE,
SEX, STND_Y, AGE_GROUP, SIDO, SGG, CTRB_PT_TYPE_CD
from sas_re.final_control_matching_indexdate
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

proc sql;
create table control_can as
select *,
	case
		when ( DIV_CD in ('S5119', 'S5111', 'S5117') ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( DIV_CD in ('S5042', 'S5049') ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( DIV_CD in ('S5372') ) then 1
		else 0
	end as KERAT,
	case
		when ( DIV_CD in ('S5121') ) then 1
		else 0
	end as VITR,
	case
		when (substr(MAIN_SICK,1,3) between 'E10' and 'E14' or substr(SUB_SICK,1,3) between 'E10' and 'E14'
			  or substr(MAIN_SICK,1,4) in ('H360') or substr(SUB_SICK,1,4) in ('H360')) then 1
		else 0
	end as DIAB,
	case
		when (substr(MAIN_SICK,1,4) in ('H442') or substr(SUB_SICK,1,4) in ('H442')) then 1
		else 0
	end as DEG_MYO
from sas_re.control_final
;run; quit;

proc sql;
create table control_a2 as
select *,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where CAT_SUR = 1) ) then 1
		else 0
	end as CAT_SUR,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where GLAU_SUR = 1) ) then 1
		else 0
	end as GLAU_SUR,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where KERAT = 1) ) then 1
		else 0
	end as KERAT,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where VITR = 1) ) then 1
		else 0
	end as VITR,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where DIAB = 1) ) then 1
		else 0
	end as DIAB,
	case
		when ( PERSON_ID in (select PERSON_ID from control_can where DEG_MYO = 1) ) then 1
		else 0
	end as DEG_MYO
from control_a1
;run; quit;

data sas_re.control_done;
set control_a2;
run;

proc sql;
select count(case when DIAB = 1  then 1 end) as cnt_diab
from  sas_re.control_done ;
run; quit;

proc sql;
select count(case when DIAB = 1  then 1 end) as cnt_diab
from  control_can ;
run; quit;
