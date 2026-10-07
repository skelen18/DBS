use bac027_dsI_2024


-- ut 17:45

------------- A

-- 1.
-- Pro každý obor FORD spadajícího do vědní oblasti 'Natural Sciences'
-- vypište kolik institucí má alespoň deset článků v prvním decilu.
-- Moje A1
with cte as (select ai.iid, zyfj.fid, count(distinct za.aid) as article_count
             from z_field_of_science fos
                      join dbo.z_field_ford zff on fos.sid = zff.sid
                      join dbo.z_year_field_journal zyfj on zff.fid = zyfj.fid
                      join dbo.z_article za on zyfj.jid = za.jid and zyfj.year = za.year
                      join z_article_institution ai on za.aid = ai.aid
             where fos.name = 'Natural sciences'
               and zyfj.ranking = 'Decil'
             group by ai.iid, zyfj.fid
             having count(distinct za.aid) >= 10)
select ff.fid, ff.name, count(*) as pocet_instituci
from z_field_ford ff
         left join cte on cte.fid = ff.fid
         join z_field_of_science fos on ff.sid = fos.sid
where fos.name = 'Natural sciences'
group by ff.fid, ff.name
order by ff.fid;


-- 2.
-- Nalezněte jména a rid osob začínající na 'Z', které publikovaly jak v oboru FORD (z_field_ford.name) `5.4 Sociology`,
-- tak v `1.4 Chemical Sciences`.
select rid, name
from z_author
where z_author.rid IN (select rid
                       from z_article_author aa
                                join z_article a on aa.aid = a.aid
                                join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                                join z_field_ford ff on yfj.fid = ff.fid
                       where ff.name = '5.4 Sociology')
  AND z_author.rid IN (select rid
                       from z_article_author aa
                                join z_article a on aa.aid = a.aid
                                join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                                join z_field_ford ff on yfj.fid = ff.fid
                       where ff.name = '1.4 Chemical Sciences')
  and z_author.name LIKE 'Z%'


-- 3.
-- Pro instituci s názvem 'Vysoká škola báňská - Technická univerzita Ostrava', spočítejte a vypište následující údaje:
-- 1. Počet různých článků, kde je autorem 'Svoboda'.
-- 2. Počet různých článků, kde žurnál má ranking 'Decil'.
-- 3. Počet různých autorů, kteří publikovali v roce 2020.

select zi.name,
       (select count(distinct a.aid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join dbo.z_article_author zaa on a.aid = zaa.aid
                 join dbo.z_author za on zaa.rid = za.rid
        where ai.iid = zi.iid
          and za.name LIKE 'Svoboda%') clanky_svoboda,
       (select count(distinct a.aid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
        where ai.iid = zi.iid
          and yfj.ranking = 'Decil')    clanky_v_decilu,
       (select count(distinct aa.rid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join z_article_author aa on a.aid = aa.aid
        where ai.iid = zi.iid
          and a.year = 2020)            pocet_unikatnich_autoru_2020
from z_institution zi
where zi.name = 'Vysoká škola báňská - Technická univerzita Ostrava'


------------- B


-- 1.
-- Pro každý obor FORD spadajícího do vědní oblasti 'Medical and Health Sciences' vypište,
-- kolik institucí má alespoň deset článků v prvním decilu.
-- Vypište fid, ford_name a počet.
with cte as (select ai.iid, zyfj.fid, count(distinct za.aid) as article_count
             from z_field_of_science fos
                      join dbo.z_field_ford zff on fos.sid = zff.sid
                      join dbo.z_year_field_journal zyfj on zff.fid = zyfj.fid
                      join dbo.z_article za on zyfj.jid = za.jid and zyfj.year = za.year
                      join z_article_institution ai on za.aid = ai.aid
             where fos.name = 'Medical and Health Sciences'
               and zyfj.ranking = 'Decil'
             group by ai.iid, zyfj.fid
             having count(distinct za.aid) >= 10)
select ff.fid, ff.name, count(*) as pocet_instituci
from z_field_ford ff
         left join cte on cte.fid = ff.fid
         join z_field_of_science fos on ff.sid = fos.sid
where fos.name = 'Medical and Health Sciences'
group by ff.fid, ff.name
order by ff.fid;



-- 2.
-- Nalezněte jména osob začínající na 'M', které publikovaly jak v oboru FORD `5.3 Education` tak v `2.3 Mechanical engineering`.
-- Vypište aid a jméno osoby.
select rid, name
from z_author
where z_author.rid IN (select rid
                       from z_article_author aa
                                join z_article a on aa.aid = a.aid
                                join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                                join z_field_ford ff on yfj.fid = ff.fid
                       where ff.name = '5.3 Education')
  AND z_author.rid IN (select rid
                       from z_article_author aa
                                join z_article a on aa.aid = a.aid
                                join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
                                join z_field_ford ff on yfj.fid = ff.fid
                       where ff.name = '2.3 Mechanical engineering')
  and z_author.name LIKE 'M%'

-- 3.
-- Pro instituci s názvem 'České vysoké učení technické v Praze', spočítejte a vypište následující údaje:
-- 1. Počet různých článků, kde je autorem 'Novak'.
-- 2. Počet různých žurnálů, které mají v roce publikování ranking 'Decil'.
-- 3. Počet různých autorů, kteří publikovali v roce 2019.


select zi.name,
       (select count(distinct a.aid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join dbo.z_article_author zaa on a.aid = zaa.aid
                 join dbo.z_author za on zaa.rid = za.rid
        where ai.iid = zi.iid
          and za.name LIKE '%Novak%') clanky_navratil,
       (select count(distinct yfj.jid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join z_year_field_journal yfj on a.jid = yfj.jid and a.year = yfj.year
        where ai.iid = zi.iid
          and yfj.ranking = 'Decil')  zurnaly_v_decilu,
       (select count(distinct aa.rid)
        from z_article_institution ai
                 join dbo.z_article a on ai.aid = a.aid
                 join z_article_author aa on a.aid = aa.aid
        where ai.iid = zi.iid
          and a.year = 2019)          pocet_unikatnich_autoru_2019
from z_institution zi
where zi.name = 'České vysoké učení technické v Praze'
