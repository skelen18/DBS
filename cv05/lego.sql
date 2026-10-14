-- Ukázková úloha 1
-- Sběratel hledá minifigurky, které v roce 2015 doprovázely rozsáhlé
-- stavebnice. Za rozsáhlou považujte takovou verzi inventáře stavebnice
-- vydané v roce 2015, která obsahuje více než 50 různých druhů běžných
-- dílků. Druhy dílků počítejte podle čísla dílku bez ohledu na barvu
-- a počítejte pouze běžné dílky (is_spare = FALSE), nikoli náhradní dílky
-- (is_spare = TRUE). Pro každou minifigurku spočítejte, v kolika různých
-- takových stavebnicích je obsažena. Stavebnici započítejte jen jednou, i když
-- vyhovuje více jejích verzí inventáře. Ponechte pouze minifigurky
-- obsažené alespoň ve čtyřech takových stavebnicích. Vypište číslo
-- minifigurky, její název, počet stavebnic a nejvyšší počet druhů
-- dílků v tomto pořadí.

-- Výsledek seřaďte vzestupně podle názvu minifigurky.
 -- HINT: Postupujte od stavebnic k minifigurkám, ne naopak. Nejprve omezte
-- inventáře na stavebnice z roku 2015 a u každého inventáře ověřte podmínku
-- na více než 50 různých čísel běžných dílků; tato podmínka je agregační,
-- proto ji vyhodnoťte uvnitř poddotazu. Teprve na vyhovující inventáře
-- napojte minifigurky. Stavebnice počítejte přes různá set_num, protože
-- jedna stavebnice může mít více verzí inventáře. Práh čtyř stavebnic
-- je podmínka nad agregací, patří tedy do HAVING.
SELECT f.fig_num,
     f.name AS minifigurka,
     COUNT(DISTINCT i.set_num) AS pocet_stavebnic,
     MAX((SELECT COUNT(DISTINCT ip.part_num)
      FROM inventory_parts ip
      WHERE ip.inventory_id = i.id
        AND ip.is_spare = FALSE)) AS nejvice_druhu_dilku
FROM minifigs f
JOIN inventory_minifigs im ON im.fig_num = f.fig_num
JOIN inventories i ON i.id = im.inventory_id
WHERE i.set_num IN (
      SELECT s.set_num
      FROM sets s
      WHERE s.year = 2015
    )
  AND EXISTS (
      SELECT 1
      FROM inventory_parts ip
      WHERE ip.inventory_id = i.id
      AND ip.is_spare = FALSE
      HAVING COUNT(DISTINCT ip.part_num) > 50
    )
GROUP BY f.fig_num, f.name
HAVING COUNT(DISTINCT i.set_num) >= 4
ORDER BY f.name;


  -- Ukázková úloha 2
-- Představte si, že vybíráte dárek pro fanouška Bionicle. Najděte stavebnice
-- z tohoto tématu vydané v letech 2006 až 2010, jejichž katalogový počet dílků
-- je vyšší než průměrný počet dílků v tématu, ale nižší než nejvyšší počet
-- dílků v tématu. Průměr a maximum počítejte ze všech stavebnic daného tématu,
-- nejen z uvedených let. Vypište číslo stavebnice, její název, rok vydání
-- a katalogový počet dílků v tomto pořadí.
-- Výsledek seřaďte sestupně podle katalogového počtu dílků a potom vzestupně
-- podle čísla stavebnice.

-- HINT: Rozlišujte dvě různá omezení. Rok 2006 až 2010 vybírá stavebnice,
-- které se objeví ve výsledku, zatímco průměr a maximum se počítají ze všech
-- stavebnic tématu. Proto do poddotazů s AVG a MAX nikdy nepište podmínku
-- na rok; ta patří pouze do vnějšího dotazu. Oba poddotazy korelujte přes
-- theme_id vnější stavebnice, aby se počítaly v rámci jejího tématu.

WITH SelThemes AS (
    SELECT L2.id
    FROM themes L1
    JOIN themes L2 ON L2.parent_id = L1.id
    WHERE L1.name = 'Bionicle'
     UNION
    SELECT L2.id
    FROM themes L1
    JOIN themes L2 ON L1.id = L2.id 
    WHERE L1.name = 'Bionicle'
  )
  SELECT s.set_num, s.name, s.year, s.num_parts
  FROM sets s
  WHERE s.theme_id IN (SELECT id FROM SelThemes)
    AND s.year BETWEEN 2006 AND 2010
    AND s.num_parts > (
      SELECT AVG(s2.num_parts)
      FROM sets s2
      WHERE s2.theme_id = s.theme_id
    )
    AND s.num_parts < (
      SELECT MAX(s2.num_parts)
      FROM sets s2
      WHERE s2.theme_id = s.theme_id
    )
ORDER BY s.num_parts DESC, s.set_num;


-- na zbytek seru picovina, wish me luck na testu :pray: