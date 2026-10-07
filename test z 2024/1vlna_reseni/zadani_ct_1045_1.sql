-- ct 10:45, 1. termín
------------- A

-- 1.
-- Pro každou instituci (iid a jméno) z Prahy (z_institution.town začíná na Praha) 
-- nalezněte autora/autory (rid a jméno) s nejvyšším počtem článků v prvním decilu
-- (z_year_field_journal.ranking='Decil'). Neuvažujte instituce bez takových článků.
-- Setřiďte sestupně podle počtu článků.

-- Poznámky:
-- V databázi není vazba Autor - Instituce, je nutné získat články instituce a autory těchto článků.
-- Nezapomeňte, že jeden článek se může vázat na více záznamů v tabulce z_year_field_journal,
-- pro každou hodnotu ranking počítejte článek pouze jednou.

-- Řešení:
with tab as (
  select i.iid as iid, i.name as inst_name, ar.rid as rid, ar.name as author_name, 
    count(distinct a.aid) as article_count 
  from z_institution i
  join z_article_institution ai on ai.iid=i.iid
  join z_article a on ai.aid=a.aid
  join z_year_field_journal yfj on yfj.year=a.year and yfj.jid=a.jid
  join z_article_author aa on a.aid=aa.aid
  join z_author ar on aa.rid=ar.rid
  where i.town like 'Praha%' and yfj.ranking='Decil'
  group by i.iid, i.name, ar.rid, ar.name
)
select * from tab t1
where t1.article_count >= all (
  select t2.article_count from tab t2
  where t1.iid=t2.iid
)
order by t1.article_count desc

/*
Příklad výsledku:
iid	inst_name	rid	author_name	article_count
197	Vysoká škola chemicko-technologická v Praze	218838	Pumera, Martin	142
146	Univerzita Karlova	115216	Chen, Y.	88
35	České vysoké učení technické v Praze	1479	Adamczyk, L.	49
114	Nemocnice Na Homolce	192868	Neuzil, Petr	42
52	Fyzikální ústav AV ČR v.v.i.	116819	Choi, K.	39
156	Ústav experimentální botaniky AV ČR v.v.i.	62750	Dolezel, Jaroslav	38
156	Ústav experimentální botaniky AV ČR v.v.i.	195712	Novak, Ondrej	38
85	Mikrobiologický ústav AV ČR v.v.i.	15671	Baldrian, Petr	35
49	Fakultní nemocnice v Motole	256603	Stary, Jan	31
191	Všeobecná fakultní nemocnice v Praze	272294	Trneny, Marek	30
...
*/

-- 2. 
-- Nalezněte jména osob, které jsou autory článku/článků v časopise s ISSN 0004-3702, 
-- ale nejsou autory článku/článků v časopise s ISSN 2169-3536. Výsledek bude setřízen dle rid 
-- autora.

-- Řešení 1:
select distinct ar.rid as rid, ar.name as author_name from z_author ar
join z_article_author aa on ar.rid=aa.rid
join z_article a on aa.aid=a.aid
join z_journal j on a.jid=j.jid
where j.issn='0004-3702' and ar.rid not in (
  select distinct ar2.rid as rid from z_author ar2
  join z_article_author aa2 on ar2.rid=aa2.rid
  join z_article a2 on aa2.aid=a2.aid
  join z_journal j2 on a2.jid=j2.jid
  where j2.issn='2169-3536'
)
order by ar.rid;

-- Řešení 2:
select a.name
from z_author a
where a.rid in (
  select aa.rid
  from z_article_author aa
  join z_article e on e.aid = aa.aid
  join z_journal j on j.jid = e.jid
  where j.issn = '0004-3702'
) and a.rid not in (
  select aa.rid
  from z_article_author aa
  join z_article e on e.aid = aa.aid
  join z_journal j on j.jid = e.jid
  where j.issn = '2169-3536'
)

/*
Příklad výsledku: 20 záznamů
rid	author_name
14553	Bahnik, Stepan
31096	Bosansky, Branislav
44498	Cermak, Jiri
67102	Dvorak, Pavel
68512	Eiben, Eduard
81081	Froleyks, Nils
81496	Fuernkranz, Johannes
83721	Ganian, Robert
...
*/

-- 3.
-- Zjistěte následující statistiky pro každý obor FORD ve vědní oblasti 'Engineering and Technology'
-- (z_field_of_science.name):
-- 1. Celkový počet článků.
-- 2. Počet článků v prvním decilu (z_year_field_journal.ranking='Decil').
-- 3. Počet článků instituce 'Vysoká škola báňská - Technická univerzita Ostrava'.

-- Výsledek setřiďte dle jména oboru FORD.

-- Řešení:
select ff.name,
(
  select count(a1.aid) from z_article a1
  join z_year_field_journal yfj1 on yfj1.jid=a1.jid and yfj1.year=a1.year
  where yfj1.fid=ff.fid
) as article_count,
(
  select count(a2.aid) from z_article a2
  join z_year_field_journal yfj2 on yfj2.jid=a2.jid and yfj2.year=a2.year 
  where yfj2.fid=ff.fid and yfj2.ranking='Decil'
) as article_count_d1,
(
  select count(a3.aid) from z_article a3
  join z_article_institution ai3 on a3.aid=ai3.aid
  join z_institution i3 on ai3.iid=i3.iid 
  join z_year_field_journal yfj3 on yfj3.jid=a3.jid and yfj3.year=a3.year 
  where yfj3.fid=ff.fid and i3.name='Vysoká škola báňská - Technická univerzita Ostrava' 
) as article_count_vsb
from z_field_ford ff
join z_field_of_science fs on fs.sid=ff.sid
where fs.name='Engineering and Technology'
order by ff.name;

/*
Příklad výsledku: 11 záznamů
name	article_count	article_count_d1	article_count_vsb
2.1 Civil engineering	638	82	54
2.10 Nano-technology	1738	246	138
2.11 Other engineering and technologies	10453	744	309
2.2 Electrical engineering, electronic engineering, information engineering	2344	217	280
2.3 Mechanical engineering	2199	231	85
2.4 Chemical engineering	1218	218	97
2.5 Materials engineering	7670	785	667
2.6 Medical engineering	605	56	15
2.7 Environmental engineering	3218	464	309
2.8 Environmental biotechnology	916	151	11
2.9 Industrial biotechnology	274	24	13
*/

------------- B

-- 1.
-- Pro každou instituci (iid a jméno) z Ostravy (z_institution.town začíná na Ostrava) 
-- nalezněte autora/autory (rid a jméno) s nejvyšším počtem článků v prvním decilu
-- (z_year_field_journal.ranking='Decil'). Neuvažujte instituce bez takových článků.
-- Setřiďte sestupně podle počtu článků.

-- Poznámky:
-- V databázi není vazba Autor - Instituce, je nutné získat články instituce a autory těchto článků.
-- Nezapomeňte, že jeden článek se může vázat na více záznamů v tabulce z_year_field_journal,
-- pro každou hodnotu ranking počítejte článek pouze jednou.

-- Řešení:
with tab as (
  select i.iid as iid, i.name as inst_name, ar.rid as rid, ar.name as author_name, 
    count(distinct a.aid) as article_count 
  from z_institution i
  join z_article_institution ai on ai.iid=i.iid
  join z_article a on ai.aid=a.aid
  join z_year_field_journal yfj on yfj.year=a.year and yfj.jid=a.jid
  join z_article_author aa on a.aid=aa.aid
  join z_author ar on aa.rid=ar.rid
  where i.town like 'Ostrava%' and yfj.ranking='Decil'
  group by i.iid, i.name, ar.rid, ar.name
)
select * from tab t1
where t1.article_count >= all (
  select t2.article_count from tab t2
  where t1.iid=t2.iid
)
order by t1.article_count desc

/*
Příklad výsledku:
iid	inst_name	rid	author_name	article_count
46	Fakultní nemocnice Ostrava	98045	Hajek, Roman	53
118	Ostravská univerzita	98045	Hajek, Roman	44
193	Vysoká škola báňská - Technická univerzita Ostrava	299355	Zboril, Radek	21
163	Ústav geoniky AV ČR v.v.i.	263277	Sysala, Stanislav	2
163	Ústav geoniky AV ČR v.v.i.	106241	Hloch, Sergej	2
227	Zdravotní ústav se sídlem v Ostravě	109831	Hoyer, Lois L.	1
227	Zdravotní ústav se sídlem v Ostravě	111269	Hubka, Vit	1
...
*/

-- 2. 
-- Nalezněte jména osob, které jsou autory článku/článků v časopise s ISSN 0012-9682, 
-- ale nejsou autory článku/článků v časopise s ISSN 0022-0531. Výsledek bude setřízen dle 
-- rid autora.

-- Řešení 1:
select distinct ar.rid as rid, ar.name as author_name from z_author ar
join z_article_author aa on ar.rid=aa.rid
join z_article a on aa.aid=a.aid
join z_journal j on a.jid=j.jid
where j.issn='0012-9682' and ar.rid not in (
  select distinct ar2.rid as rid from z_author ar2
  join z_article_author aa2 on ar2.rid=aa2.rid
  join z_article a2 on aa2.aid=a2.aid
  join z_journal j2 on a2.jid=j2.jid
  where j2.issn='0022-0531'
)
order by ar.rid;

-- Řešení 2:
select a.name
from z_author a
where a.rid in (
  select aa.rid
  from z_article_author aa
  join z_article e on e.aid = aa.aid
  join z_journal j on j.jid = e.jid
  where j.issn = '0012-9682'
) and a.rid not in (
  select aa.rid
  from z_article_author aa
  join z_article e on e.aid = aa.aid
  join z_journal j on j.jid = e.jid
  where j.issn = '0022-0531'
)

/*
Příklad výsledku:
rid	author_name
258246	Stewart, Colin
*/

-- 3.
-- Zjistěte následující statistiky pro každý obor FORD ve vědní oblasti 'Natural sciences' 
-- (z_field_of_science.name):
-- 1. Celkový počet článků.
-- 2. Počet článků v časopisech v prvním kvartilu (z_year_field_journal.ranking='Q1').
-- 3. Počet jedinečných autorů s článkem/články v časopisech v prvním decilu 
--      (z_year_field_journal.ranking='Decil').

-- Výsledek setřiďte dle jména oboru FORD.

-- Řešení:
select ff.name,
(
  select count(a1.aid) from z_article a1
  join z_year_field_journal yfj1 on yfj1.jid=a1.jid and yfj1.year=a1.year
  where yfj1.fid=ff.fid
) as article_count,
(
  select count(a2.aid) from z_article a2
  join z_year_field_journal yfj2 on yfj2.jid=a2.jid and yfj2.year=a2.year 
  where yfj2.fid=ff.fid and yfj2.ranking='Q1'
) as article_count_q1,
(
  select count(distinct ar3.rid) from z_author ar3
  join z_article_author aa3 on ar3.rid=aa3.rid
  join z_article a3 on a3.aid=aa3.aid 
  join z_year_field_journal yfj3 on yfj3.jid=a3.jid and yfj3.year=a3.year 
  where yfj3.fid=ff.fid and yfj3.ranking='Decil' 
) as author_count_d1
from z_field_ford ff
join z_field_of_science fs on fs.sid=ff.sid
where fs.name='Natural sciences'
order by ff.name;

/*
Příklad výsledku: 7 záznamů
name	article_count	article_count_q1	author_count_d1
1.1 Mathematics	3921	573	400
1.2 Computer and Information Sciences	2523	416	2282
1.3 Physical Sciences	11712	4187	18082
1.4 Chemical Sciences	13712	3525	6005
1.5 Earth and Related Environmental Sciences	7844	1867	9771
1.6 Biological Sciences	14383	3670	22563
1.7 Other Natural Sciences	2823	629	16632
*/