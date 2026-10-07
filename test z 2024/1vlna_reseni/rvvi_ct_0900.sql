
-- 1.
-- Vypi�te rid a jm�no osob, kter� m�ly v ka�d�m roce (2017, 2018, 2019, 2020) alespo� patn�ct �l�nk� v prvn�m decilu
select rid, author_name
from (
	select au.rid, au.name author_name, a.year
	from z_article_author aa 
	join z_article a on a.aid = aa.aid
	join z_author au on au.rid = aa.rid
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	where j.ranking = 'Decil' and a.year in (2017, 2018, 2019, 2020)
	group by au.rid, au.name, a.year
	having COUNT(distinct a.aid) >= 15
) t
group by t.rid, t.author_name
having COUNT(*) = 4



-- 2.
-- Nalezn�te osoby, kter� napsaly �l�nek se spoluautory 'Baca, Radim' a 'Kratky, Michal'.
-- Vynechte z v�sledku tyto dv� osoby, vypi�te jejich rid a jm�no a set�i�te podle rid.
-- Nevypisujte duplicity.
select a.rid, a.name
from z_author a
where a.rid in 
(
	select aa.rid
	from z_article_author aa
	where aa.aid in (
		select aid
		from z_author a
		join z_article_author aa on a.rid = aa.rid
		where a.name = 'Baca, Radim'
	) and aa.aid in (
		select aid
		from z_author a
		join z_article_author aa on a.rid = aa.rid
		where a.name = 'Kratky, Michal'
	) and a.name NOT IN ('Baca, Radim', 'Kratky, Michal')
)
order by a.rid

-- 3
-- Nalezn�te �l�nek(y) ve v�dn� oblasti 'Natural sciences' (tabulka z_field_of_science) s nejv�t��m mno�stv�m autor�. 
-- Vypi�te aid, jm�no �l�nku a po�et autor�.
with tab as (
	select a.aid, a.name, COUNT(DISTINCT aa.rid) pocet
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Natural sciences'
	group by a.aid, a.name
)
select *
from tab
where pocet >= all(
	select pocet
	from tab
)

-- Mozno vyuzit i author_count, nicmene vysledek bude jiny (nekonzistence v databazi).
with tab as (
	select a.aid, a.name, a.author_count
	from z_article a
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Natural sciences'
)
select *
from tab
where author_count >= all(
	select author_count
	from tab
)



------------- B
-- 1. (stejne jako u 1.A)
-- Vypi�te rid a jm�no osob, kter� m�ly v ka�d�m roce (2017, 2018, 2019, 2020) alespo� patn�ct �l�nk� v prvn�m decilu
select rid, author_name
from (
	select au.rid, au.name author_name, a.year
	from z_article_author aa 
	join z_article a on a.aid = aa.aid
	join z_author au on au.rid = aa.rid
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	where j.ranking = 'Decil' and a.year in (2017, 2018, 2019, 2020)
	group by au.rid, au.name, a.year
	having COUNT(distinct a.aid) >= 15
) t
group by t.rid, t.author_name
having COUNT(*) = 4


-- 2.
-- Nalezn�te osoby, kter� napsaly �l�nek se spoluautory 'Horak, Pavel' a 'Kudelka, Milos'.
-- Vynechte z v�sledku tyto dv� osoby, vypi�te jejich rid a jm�no a set�i�te podle rid.
-- Nevypisujte duplicity.
select a.rid, a.name
from z_author a
where a.rid in 
(
	select aa.rid
	from z_article_author aa
	where aa.aid in (
		select aid
		from z_author a
		join z_article_author aa on a.rid = aa.rid
		where a.name = 'Kudelka, Milos'
	) and aa.aid in (
		select aid
		from z_author a
		join z_article_author aa on a.rid = aa.rid
		where a.name = 'Horak, Pavel'
	) and a.name NOT IN ('Horak, Pavel', 'Kudelka, Milos')
)
order by a.rid



-- 3
-- Nalezn�te �l�nek(y) ve v�dn� oblasti 'Social sciences' (tabulka z_field_of_science) s nejv�t��m mno�stv�m autor�. 
-- Vypi�te aid, jm�no �l�nku a po�et autor�.
with tab as (
	select a.aid, a.name, COUNT(DISTINCT aa.rid) pocet
	from z_article a
	join z_article_author aa on a.aid = aa.aid
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Social sciences'
	group by a.aid, a.name
)
select *
from tab
where pocet >= all(
	select pocet
	from tab
)

-- Mozno vyuzit i author_count, nicmene vysledek bude jiny (nekonzistence v databazi).
with tab as (
	select a.aid, a.name, a.author_count
	from z_article a
	join z_year_field_journal j on j.jid = a.jid and j.year = a.year
	join z_field_ford ff on j.fid = ff.fid
	join z_field_of_science fs on ff.sid = fs.sid
	where fs.name = 'Social sciences'
)
select *
from tab
where author_count >= all(
	select author_count
	from tab
)
