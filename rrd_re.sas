libname final "D:\RRD\final";
libname sas "D:\RRD\sas";
libname sas_re "D:\RRD\sas_re";

/* 1. 안과 방문 정의 - T30에서 분류코드 DIV_CD = 'E6810', 'EY791', 'EY792', 'EY799' 세극등현미경검사의 KEY_SEQ 찾기 */
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

/*2. t20의 PERSON_ID와 t30 세극등현미경검사의 KEY_SEQ join*/
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

/*t20-t30 연결*/
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

/*3. 해당 PERSON_ID로 t30 모든 KEY_SEQ 가져오기*/
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

/* 제외대상자 */
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

/*제외대상자제거*//*id 기준으로 제거됨*/
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
< 필요변수 >
PERSON_ID 개인일련번호 t20
KEY_SEQ 청구일련번호 t20, t30
SEQ_NO 일련번호 t30
RECU_FR_DT 요양개시일자  t20, t30
DSBJT_CD 진료과목코드(내과,신경과,안과,이비인후과등)  t20
MAIN_SICK 주상병 ICD-10 코드  t20
SUB_SICK 부상병 ICD-10 코드 t20
DIV_CD 분류코드 EDI 코드  t30
TOT_PRES_DD_CNT 총처방일수  t20
MDCN_EXEC_FREQ 총투여일수또는실시횟수  t30
MPRSC_GRANT_NO 처방전발행기관식별대체번호  t20
YKIHO_ID 요양기관식별대체번호  t20
*/

/*필요변수 정리*/
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

/*안과방문사례 진료과목코드 DSBJT_CD = '12' 안과*/
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

/*RECU_FR_DT 요양개시일 char -> date*/
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

/*Entry Date 만들기*/
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

/*RRD 진단 케이스 PERSON_ID 생성*/
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

/*RRD 진단 케이스 제외 대상자  PERSON_ID 생성*/
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

/*RRD 진단 케이스 제외 대상자 제거한 총 PERSON_ID*/
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

/*RRD 진단 케이스 ID의 전체 OBS 가져오기*/
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

/* DIV_CD ('S5130', 'S5121') 수술 진단 */
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
/*RECU_FR_DT = ENTRY_DATE에 DIV_CD ('S5130', 'S5121') 수술없이 
MAIN_SICK ('H330', 'H335') SUB_SICK ('H330', 'H335') RD 진단*/
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

/*Index Date 만들기*/
/*RRD 진단 케이스 ID의 전체 OBS 가져오기*/
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

/*다시*/
/*Index Date 만들기*/
/*RRD 진단 케이스 제외 대상자 제거한 총 PERSON_ID*/
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

/*ID별 INDEX_DATE 테이블*/
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

/*RRD 진단 케이스 ID의 전체 OBS에 INDEX_DATE 테이블 이너조인*/
/*RRD 진단 케이스 ID의 전체 OBS 에 이너조인*/
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

/*Confounding Factors 교란요인 */
/*Keratoplasty 각막성형술 S5372*/
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

/*Confounding Factors 교란요인*/
/*전체 Comorbidities 동반상병*/
/*
Cataract surgery 백내장 수술 'S5119', 'S5111', 'S5117'
Glaucoma surgery 녹내장수술 'S5042', 'S5049'
Keratoplasty 각막성형술 'S5372'
Vitrectomy 유리체절제술 'S5121'
Diabetes 당뇨병 'E10' - 'E14', 'H360'
Degenerative myopia 퇴행성 근시 'H442'
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

/*Case Final Indexdate 테이블에 자격 DB 변수 추가*/
/*자격DB - SEX 성 / STND_Y 기준년도 / AGE_GROUP 기준년도 나이 / SIDO 시도코드/ SGG 시군구 / CTRB_PT_TYPE_CD 보험료소득분위 추가*/
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

/*work library에 임시 datechange 파일*/
data case_final_indexdate;
set sas_re.case_final_indexdate;
YYYY = put(RECU_FR_DT, year4.);
format YYYY $4.;
run;

/*STND_Y별 AGE_GROUP 붙이기*/
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

/*Final Case 군*/
/*Confounding Factors 교란요인+자격DB*/
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

/*Control 군*/
/*RRD 진단 케이스 제외 PERSON_ID 생성*/
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

/*Confounding Factors 교란요인*/
/*전체 Comorbidities 동반상병*/
/*
Cataract surgery 백내장 수술 'S5119', 'S5111', 'S5117'
Glaucoma surgery 녹내장수술 'S5042', 'S5049'
Keratoplasty 각막성형술 'S5372'
Vitrectomy 유리체절제술 'S5121'
Diabetes 당뇨병 'E10' - 'E14', 'H360'
Degenerative myopia 퇴행성 근시 'H442'
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

/*Control Final 테이블에 자격 DB 변수 추가*/
/*자격DB - SEX 성 / STND_Y 기준년도 / AGE_GROUP 기준년도 나이 / SIDO 시도코드/ SGG 시군구 / CTRB_PT_TYPE_CD 보험료소득분위 추가*/
/*Control*//* ID = 793,892 *//* OBS = 25,006,608*/

/*work library에 임시 datechange 파일*/
data control_final;
set sas_re.control_final;
YYYY = put(RECU_FR_DT, year4.);
format YYYY $4.;
run;

/*STND_Y별 AGE_GROUP 붙이기*/
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

/*Final Control 군*/
/*Confounding Factors 교란요인+자격DB*/
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

/*work library에서 작업한 matching final 테이블 ID로 코호트 가져오기*/
/*case_id = 1,345명*//*control_id = 13,450명*//*전체 obs = 13,450*/

/*Case Final (w/ confounders and 자격DB)*/
proc sql;
create table sas_re.final_case_matching as
select * 
from sas_re.final_case
where final_case.PERSON_ID in (select distinct(case_id) from sas_re.matching_final)
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

/*원래 case = 1,665명*//*매칭 case = 1,345명*/
/*OBS 267,912건 -> 221,769건*/
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

/*Control Final (w/ confounders and 자격DB)*/
proc sql;
create table sas_re.final_control_matching as
select * from sas_re.final_control
where final_control.PERSON_ID in (select distinct(control_id) from sas_re.matching_final)
order by PERSON_ID, RECU_FR_DT, KEY_SEQ, SEQ_NO
; quit;

/*원래 control = 793,892명*//*매칭 control = 13,450명*/
/*OBS 25,006,608건 -> 678,828건*/
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

/*control 테이블에 index_date = null 처리*/
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

/*case군 control군 union*/
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
