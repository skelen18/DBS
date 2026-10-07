-- Ut 14:15
------------- A
-- 1.
-- Pro každý obor FORD ve vědní oblasti 'Natural sciences', vypište instituci s nejvyšším 
-- počtem článků v prvním decilu (z_field_of_science.ranking='Decil'). Vypište náze oboru, 
-- název instituce a počet článků v první decilu.
-- Poznámka: nezapomeňte, že nejvyšší počet článků může mít více institucí.

-- Řešení (Michal): rank
select rt.field_ford, rt.instituce, rt.pocet_clanku 
from (
  select 
    rank () over (
	  partition by ff.name
	  order by ff.name,count(*) desc
	) as row_number, 
    i.iid, i.name as instituce, ff.name as field_ford, 
	count(distinct a.aid) as pocet_clanku 
  from z_article a
  join z_year_field_journal yfj on a.year=yfj.year and a.jid=yfj.jid
  join z_article_institution ai on a.aid=ai.aid
  join z_institution i on ai.iid=i.iid
  join z_field_ford ff on yfj.fid=ff.fid
  join z_field_of_science fs on ff.sid=fs.sid
  where yfj.ranking='Decil' and fs.name='Natural sciences'
  group by i.iid, i.name, ff.name
) as rt
where rt.row_number=1;

-- Řešení (Radim): CTE-all
with tab as (
  select 
    i.iid, i.name as univerzita, ff.name as field_ford, 
	count(*) as pocet_clanku 
  from z_article a
  join z_year_field_journal yfj on a.year=yfj.year and a.jid=yfj.jid
  join z_article_institution ai on a.aid=ai.aid
  join z_institution i on ai.iid=i.iid
  join z_field_ford ff on yfj.fid=ff.fid
  join z_field_of_science fs on ff.sid=fs.sid
  where yfj.ranking='Decil' and fs.name='Natural sciences'
  group by i.iid, i.name, ff.name
)
select t1.field_ford, t1.univerzita,t1.pocet_clanku from tab t1
where t1.pocet_clanku >= all (
  select t2.pocet_clanku from tab t2
  where t2.field_ford=t1.field_ford
)


-- 2. 
-- Nalezněte instituce, které měly více článků v prvním decilu 
-- (hodnota z_year_field_journal.ranking='Decil') než v posledním kvartilu (hodnota 'Q4') 
-- a které mají v názvu slovo 'chemie'. Kromě iid a jména instituce, vypište také počty článků
-- v prvním decilu a posledním kvartilu.
-- Nezapomeňte, že jeden článek se může vázat na více záznamů v tabulce z_year_field_journal,
-- pro každou hodnotu ranking počítejte článek pouze jednou.

-- Řešení (Michal): CTE
with tab as (
  select i.iid as iid, i.name as instituce, yfj.ranking as ranking, 
  count(distinct a.aid) pocet_clanku
  from z_institution i
  join z_article_institution ai on i.iid=ai.iid
  join z_article a on ai.aid=a.aid
  join z_year_field_journal yfj on a.year=yfj.year and a.jid=yfj.jid
  where i.name like '%chemie%'
  group by i.iid, i.name, yfj.ranking
)
select t1.iid, t1.instituce, t1.pocet_clanku as pocet_clanku_decil, 
  (select t3.pocet_clanku from tab t3 where t3.iid=t1.iid and t3.ranking='Q4') as pocet_clanku_q4
from tab t1 
where t1.ranking='Decil' and 
  t1.pocet_clanku > (
    select t2.pocet_clanku from tab t2
	where t1.iid=t2.iid and t2.ranking='Q4'
  )

-- Řešení (Radim): poddotazy v projekci
select * 
from (
	select i.iid, 
		i.name, 
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil'
		) clanky_v_prvnim_decilu,
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Q4'
		) clanky_v_poslednim_kartilu
	from z_institution i
	where name LIKE '%chemie%'
) t
where clanky_v_prvnim_decilu > clanky_v_poslednim_kartilu


-- 3. 
-- Nalezněte instituce z Brna, které nikdy nepublikovaly ve vědní oblasti 'Natural sciences' 
-- (z_field_of_science.name) a které mají v názvu slovo 'ústav'.

-- Řešení (Michal): left join - group by - having
select i.iid, i.name as instituce
from z_institution i
left join z_article_institution ai on i.iid=ai.iid
left join z_article a on ai.aid=a.aid
left join z_year_field_journal yfj on yfj.year=a.year and yfj.jid=a.jid
left join z_field_ford ff on yfj.fid=ff.fid
left join z_field_of_science fs on ff.sid=ff.sid and fs.name='Natural sciences'
where i.town='Brno' and i.name like '%ústav%'
group by i.iid, i.name
having count(fs.sid) = 0;

-- Řešení (Radim): not in
select i.*
from z_institution i
where i.iid not in (
	select ai.iid
	from z_article_institution ai
	join z_article a on a.aid = ai.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Natural sciences'
) and i.name LIKE '%ústav%' and i.town = 'Brno' 


------------- B
-- 1.
-- Pro každý obor FORD ve vědní oblasti 'Social Sciences', vypište instituci s nejvyšším 
-- počtem článků v prvním decilu (hodnota z_field_of_science.rating='Decil'). 
-- Vypište id instituce, jméno instituce, název oboru FORD a počet článků v prvním decilu.
-- Výsledek bude setřízen dle oboru FORD.
-- Nezapomeňte, že institucí s nejvyšším počtem článků může být více.


-- Řešení (Michal, Radim - pravděpodobně stejné): CTE - >= all
with tab as (
  select i.iid as iid, i.name as instituce, ff.fid as obor_ford_id, ff.name as obor_ford, 
    count(a.aid) as pocet_clanku_decil
  from z_institution i
  join z_article_institution ai on i.iid=ai.iid
  join z_article a on ai.aid=a.aid
  join z_year_field_journal yfj on yfj.year=a.year and yfj.jid=a.jid
  join z_field_ford ff on yfj.fid=ff.fid
  join z_field_of_science fs on ff.sid=fs.sid
  where fs.name='Social Sciences' and yfj.ranking='Decil'
  group by i.iid, i.name, ff.fid, ff.name
)
select t1.iid, t1.instituce, t1.obor_ford, t1.pocet_clanku_decil from tab t1 
where t1.pocet_clanku_decil >= all (
  select t2.pocet_clanku_decil from tab t2
  where t2.obor_ford_id=t1.obor_ford_id
)
order by t1.obor_ford


-- 2. 
-- Nalezněte instituce, které měly více článků v prvním decilu 
-- (hodnota z_year_field_journal.ranking='Decil') než v posledním kvartilu (hodnota 'Q4') 
-- a které jsou z 'Prahy 6' (z_institution.town). Kromě iid a jména instituce, vypište také počty článků
-- v prvním decilu a posledním kvartilu.
-- Nezapomeňte, že jeden článek se může vázat na více záznamů v tabulce z_year_field_journal,
-- pro každou hodnotu ranking počítejte článek pouze jednou.

-- Řešení (Michal): CTE
with tab as (
  select i.iid as iid, i.name as instituce, yfj.ranking as ranking, 
  count(distinct a.aid) pocet_clanku
  from z_institution i
  join z_article_institution ai on i.iid=ai.iid
  join z_article a on ai.aid=a.aid
  join z_year_field_journal yfj on a.year=yfj.year and a.jid=yfj.jid
  where i.town='Praha 6'
  group by i.iid, i.name, yfj.ranking
)
select t1.iid, t1.instituce, t1.pocet_clanku as pocet_clanku_decil, 
  (select t3.pocet_clanku from tab t3 where t3.iid=t1.iid and t3.ranking='Q4') as pocet_clanku_q4
from tab t1 
where t1.ranking='Decil' and 
  t1.pocet_clanku > (
    select t2.pocet_clanku from tab t2
	where t1.iid=t2.iid and t2.ranking='Q4'
  )

-- Řešení (Radim): poddotazy v projekci
select * 
from (
	select i.iid, 
		i.name, 
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil'
		) clanky_v_prvnim_decilu,
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Q4'
		) clanky_v_poslednim_kartilu
	from z_institution i
	where town = 'Praha 6'
) t
where clanky_v_prvnim_decilu > clanky_v_poslednim_kartilu


-- 3. 
-- Nalezněte instituce z Olomouce vytvořené po roce 2000, 
-- které nikdy nepublikovaly ve vědní oblasti 'Engineering and Technology' (z_field_of_science.name).


-- Řešení (Michal): left join - group by - having
select i.iid, i.name as instituce
from z_institution i
left join z_article_institution ai on i.iid=ai.iid
left join z_article a on ai.aid=a.aid
left join z_year_field_journal yfj on yfj.year=a.year and yfj.jid=a.jid
left join z_field_ford ff on yfj.fid=ff.fid
left join z_field_of_science fs on ff.sid=ff.sid and fs.name='Engineering and Technology'
where i.town='Olomouc' and year(i.created) > 2000
group by i.iid, i.name
having count(fs.sid) = 0;

-- Řešení (Radim): not in
select i.*
from z_institution i
where i.iid not in (
	select ai.iid
	from z_article_institution ai
	join z_article a on a.aid = ai.aid
	join z_year_field_journal j on a.jid = j.jid and a.year = j.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Engineering and Technology'
) and i.town = 'Olomouc' and YEAR(i.created) > 2000
