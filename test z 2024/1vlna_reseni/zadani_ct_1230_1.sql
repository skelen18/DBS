-- ct 12:30, 1. termín

------------- A

-- 1.
-- Nalezněte obory FORD, ve kterých nejsou články osob (přesněji časopisy článků osob), která mají články 
-- v oboru FORD '2.1 Civil engineering' (z_field_ford.name='2.1 Civil engineering').

-- Řešení 1: Podobné jako Řešení 2, ale ff2.fid namísto yfj2.fid způsobuje vykonávání 0s.
-- U Řešení 2 trvá vykonání 15s.
select ff.name from z_field_ford ff
where ff.fid not in (
  select ff2.fid from z_article_author aa2
  join z_article a2 on aa2.aid=a2.aid
  join z_year_field_journal yfj2 on yfj2.jid=a2.jid and yfj2.year=a2.year
  join z_field_ford ff2 on yfj2.fid=ff2.fid
  where aa2.rid in (
    select aa3.rid from z_article_author aa3
    join z_article a3 on aa3.aid=a3.aid
    join z_year_field_journal yfj3 on yfj3.jid=a3.jid and yfj3.year=a3.year
    join z_field_ford ff3 on yfj3.fid=ff3.fid
    where ff3.name='2.1 Civil engineering'
  )
)

-- Řešení 2:
select *
from z_field_ford ff
where ff.fid not in (
	select fid
	from z_year_field_journal j
	join z_article a on a.jid = j.jid and a.year = j.year
	join z_article_author aa on a.aid = aa.aid
	where aa.rid in (
		select rid
		from z_article_author aa
		join z_article a on a.aid = aa.aid
		join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		join z_field_ford ff on j.fid = ff.fid
		where ff.name = '2.1 Civil engineering'
	)
)

/*
Příklad výsledku: 1 záznam
name
6.2 Languages and literature
*/

-- 2.
-- Nalezněte článek/články v prvním decilu (z_year_field_journal.ranking='Decil') s nejvyšším množstvím 
-- institucí. Vypište aid, název článku a počet institucí článku.
-- Nezapomeňte, že jeden článek, přesněji řečeno časopis, se může vázat na více záznamů v tabulce 
-- z_year_field_journal. Časopis může tedy být v prvním decilu ve více oborech, nezapomeňte 
-- na duplicity ve výsledku.

-- Řešení:
with tab as (
  select a.aid as aid,a.name as title,count(distinct ai.iid) as inst_count from z_article a
  join z_article_institution ai on a.aid=ai.aid
  join z_year_field_journal yfj on yfj.jid=a.jid and yfj.year=a.year
  where yfj.ranking='Decil'
  group by a.aid,a.name
)
select aid, title, inst_count from tab t1
where inst_count >= all (
  select t2.inst_count from tab t2
)

/*
Výsledek: 1 záznam
aid	title	inst_count
39263	Stroke 20 20: Implementation goals for intravenous thrombolysis	12
*/

-- 3.
-- Nalezněte osoby, které publikovaly článek/články v časopise v prvním decilu 
-- (z_year_field_journal.ranking='Decil') jak v oboru FORD '1.6 Biological Sciences', tak v 
-- oboru '6.4 Arts' (z_field_ford.name).

-- Řešení 1: CTE
with tab as (
  select distinct ar.rid as rid, ar.name as auth_name, ff.name as ford  from z_author ar
  join z_article_author aa on ar.rid=aa.rid
  join z_article a on aa.aid=a.aid
  join z_year_field_journal yfj on yfj.jid=a.jid and yfj.year=a.year
  join z_field_ford ff on ff.fid=yfj.fid
  where yfj.ranking='Decil'
)
select ar.rid, ar.name from z_author ar
where ar.rid in (select t1.rid from tab t1 where ford='1.6 Biological Sciences')
  and ar.rid in (select t2.rid from tab t2 where ford='6.4 Arts')

-- Řešení 2: 2 poddotazy bez CTE
select *
from z_author a
where a.rid in (
	select aa.rid
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on ff.fid = j.fid
	where ff.name = '6.4 Arts' and j.ranking = 'Decil'
) and a.rid in (
	select aa.rid
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on ff.fid = j.fid
	where ff.name = '1.6 Biological Sciences' and j.ranking = 'Decil'
)

/*
Výsledek: 1 záznam
rid	name
215874	Pospisil, Pavel
*/

------------- B

-- 1.
-- Nalezněte obory FORD, ve kterých nejsou články osob (přesněji časopisy článků osob), která mají články 
-- v oboru FORD '1.1 Mathematics' (z_field_ford.name='1.1 Mathematics').

-- Řešení 1: podobné jako Řešení 2, ale ff2.fid namísto yfj2.fid způsobuje čas vykonávání 0s. 
-- U Řešení 2 je čas vykonání 5s.
select ff.name from z_field_ford ff
where ff.fid not in (
  select ff2.fid from z_article_author aa2
  join z_article a2 on aa2.aid=a2.aid
  join z_year_field_journal yfj2 on yfj2.jid=a2.jid and yfj2.year=a2.year
  join z_field_ford ff2 on yfj2.fid=ff2.fid
  where aa2.rid in (
    select aa3.rid from z_article_author aa3
    join z_article a3 on aa3.aid=a3.aid
    join z_year_field_journal yfj3 on yfj3.jid=a3.jid and yfj3.year=a3.year
    join z_field_ford ff3 on yfj3.fid=ff3.fid
    where ff3.name='1.1 Mathematics'
  )
)

-- Řešení 2:
select *
from z_field_ford ff
where ff.fid not in (
	select fid
	from z_year_field_journal j
	join z_article a on a.jid = j.jid and a.year = j.year
	join z_article_author aa on a.aid = aa.aid
	where aa.rid in (
		select rid
		from z_article_author aa
		join z_article a on a.aid = aa.aid
		join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		join z_field_ford ff on j.fid = ff.fid
		where ff.name = '1.1 Mathematics'
	)
)

/*
Výsledek: 1záznam
name
6.4 Arts
*/

-- 2.
-- Nalezněte článek/články v oboru FORD '1.1 Mathematics' (z_field_ford.name='1.1 Mathematics') 
-- s nejvyšším množstvím institucí. Vypište aid, název článku a počet institucí článku.

-- Řešení:
with tab as (
  select a.aid as aid,a.name as title,count(distinct ai.iid) as inst_count from z_article a
  join z_article_institution ai on a.aid=ai.aid
  join z_year_field_journal yfj on yfj.jid=a.jid and yfj.year=a.year
  join z_field_ford ff on yfj.fid=ff.fid
  where ff.name='1.1 Mathematics'
  group by a.aid,a.name
)
select aid, title, inst_count from tab t1
where inst_count >= all (
  select t2.inst_count from tab t2
)

/*
Výsledek: 2 záznamy
aid	title	inst_count
2425	Influence of Duodenal-Jejunal Implantation on Glucose Dynamics: A Pilot Study Using Different Nonlinear Methods	5
21768	VOLUME ESTIMATION FROM SINGLE IMAGES: AN APPLICATION TO PANCREATIC ISLETS	5
*/

-- 3.
-- Nalezněte osoby, které publikovaly článek/články v časopise v prvním decilu 
-- (z_year_field_journal.ranking='Decil') jak v oboru FORD '5.6 Political science', tak v 
-- oboru '1.1 Mathematics' (z_field_ford.name).

-- Řešení 1: CTE
with tab as (
  select distinct ar.rid as rid, ar.name as auth_name, ff.name as ford  from z_author ar
  join z_article_author aa on ar.rid=aa.rid
  join z_article a on aa.aid=a.aid
  join z_year_field_journal yfj on yfj.jid=a.jid and yfj.year=a.year
  join z_field_ford ff on ff.fid=yfj.fid
  where yfj.ranking='Decil'
)
select ar.rid, ar.name from z_author ar
where ar.rid in (select t1.rid from tab t1 where ford='5.6 Political science')
  and ar.rid in (select t2.rid from tab t2 where ford='1.1 Mathematics')

-- Řešení 2: 2 poddotazy bez CTE
select *
from z_author a
where a.rid in (
	select aa.rid
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on ff.fid = j.fid
	where ff.name = '5.6 Political science' and j.ranking = 'Decil'
) and a.rid in (
	select aa.rid
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on ff.fid = j.fid
	where ff.name = '1.1 Mathematics' and j.ranking = 'Decil'
)

/*
Výsledky: 1 záznam
rid	name
182472	Mittag, Nikolas
*/