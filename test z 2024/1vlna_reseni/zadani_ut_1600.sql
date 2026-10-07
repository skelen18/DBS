
----------------------------------------------------
----------------------------------------------------
-- Ut 16:00

------------- A

-- 1.
-- Pro každý obor FORD z vědní oblasti `Natural Sciences' (z_field_of_science.name='Natural Sciences') spočítejte
-- kolik lidí má v daném oboru pět a více článků v prvním decilu (z_year_field_journal.ranking='Decil').
-- Neuvažujte možnost, že obor FORD nemá ani jednu takovou osobu.
with cte as (select zaa.rid, zff.name, zyfj.fid, count(*) as article_count
             from z_field_of_science fos
                      join dbo.z_field_ford zff on fos.sid = zff.sid
                      join dbo.z_year_field_journal zyfj on zff.fid = zyfj.fid
                      join dbo.z_article za on zyfj.jid = za.jid and zyfj.year = za.year
                      join dbo.z_article_author zaa on za.aid = zaa.aid
             where fos.name = 'Natural sciences'
               and zyfj.ranking = 'Decil'
             group by zaa.rid, zyfj.fid, zff.name
             having count(za.aid) >= 5)
select ff.fid, ff.name, count(*) as pocet_instituci
from z_field_ford ff
         left join cte on cte.fid = ff.fid
         join z_field_of_science fos on ff.sid = fos.sid
where fos.name = 'Natural sciences'
group by ff.fid, ff.name
order by ff.fid;


-- 2.
-- Nalezněte instituce, které mají v názvu slovo "chemie" a v roce 2017 měly více článků
-- v prvním decilu (z_year_field_journal.ranking='Decil') než v roce 2020.

select * 
from (
	select i.iid, 
		i.name, 
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil' and a.year = 2017
		) clanky_v_2017,
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil' and a.year = 2020
		) clanky_v_2020
	from z_institution i
	where name LIKE '%chemie%'
) t
where clanky_v_2017 > clanky_v_2020


-- 3.
-- Nalezněte obory FORD, ve kterých v roce 2017 nikdy nepublikovaly instituce z Brna.
-- Setřiďte výsledek podle fid.
select *
from z_field_ford
where z_field_ford.fid NOT IN (select distinct zyfj.fid
                               from z_institution zi
                                        left join dbo.z_article_institution zai on zi.iid = zai.iid
                                        left join dbo.z_article za on zai.aid = za.aid
                                        left join z_year_field_journal zyfj on za.jid = zyfj.jid and za.year = zyfj.year
                               where zi.town LIKE 'Brno%'
                                 and zyfj.year = 2017
                               group by zyfj.fid)
order by fid;



------------- B

-- 1.
-- Pro každý obor FORD z vědní oblasti `Social Sciences'  (z_field_of_science.name='Social Sciences') spočítejte
-- kolik lidí má v daném oboru tři a více článků v prvním decilu (z_year_field_journal.ranking='Decil').
-- Neuvažujte možnost, že obor FORD nemá ani jednu takovou osobu.
with cte as (select zaa.rid, zff.name, zyfj.fid, count(*) as article_count
             from z_field_of_science fos
                      join dbo.z_field_ford zff on fos.sid = zff.sid
                      join dbo.z_year_field_journal zyfj on zff.fid = zyfj.fid
                      join dbo.z_article za on zyfj.jid = za.jid and zyfj.year = za.year
                      join dbo.z_article_author zaa on za.aid = zaa.aid
             where fos.name = 'Social Sciences'
               and zyfj.ranking = 'Decil'
             group by zaa.rid, zff.name, zyfj.fid
             having count(*) >= 3)
select ff.fid, ff.name, count(cte.fid) as pocet_instituci
from z_field_ford ff
         left join cte on cte.fid = ff.fid
         join z_field_of_science fos on ff.sid = fos.sid
where fos.name = 'Social Sciences'
group by ff.fid, ff.name
order by ff.fid;



-- 2.
-- Nalezněte instituce z Prahy 6 (z_institution.town='Praha 6'), které měly v roce 2020 více článků
-- v prvním decilu (z_year_field_journal.ranking='Decil') než v roce 2019.
select * 
from (
	select i.iid, 
		i.name, 
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil' and a.year = 2019
		) clanky_v_2019,
		(
		   select COUNT(distinct a.aid)
		   from z_article_institution ai 
		   join z_article a on a.aid = ai.aid
		   join z_year_field_journal j on a.jid = j.jid and a.year = j.year
		   where ai.iid = i.iid and j.ranking = 'Decil' and a.year = 2020
		) clanky_v_2020
	from z_institution i
	where town LIKE 'Praha 6%'
) t
where clanky_v_2019 < clanky_v_2020



-- 3.
-- Nalezněte obory FORD ve kterých nikdy nepublikovali instituce z Ostravy v prvním Decilu.
-- Setřiďte výsledek podle fid.
select *
from z_field_ford
where z_field_ford.fid NOT IN (select distinct zyfj.fid
                               from z_institution zi
                                        left join dbo.z_article_institution zai on zi.iid = zai.iid
                                        left join dbo.z_article za on zai.aid = za.aid
                                        left join z_year_field_journal zyfj on za.jid = zyfj.jid and za.year = zyfj.year
                               where zi.town LIKE 'Ostrava%'
                                 and zyfj.ranking = 'Decil'
                               group by zyfj.fid)
order by fid;


