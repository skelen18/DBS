/*
   LEGO databaze - hlavni tahak

   Detailni priklady jsou rozdelene do souboru podle tematu:
   00_prehled.md          tabulky, vztahy a nejcastejsi pasti
   01_zaklady.sql         SELECT, WHERE, LIKE, NULL, boolean
   02_joiny.sql           JOIN, LEFT JOIN, self JOIN a vazebni tabulky
   03_agregace.sql        COUNT, SUM, GROUP BY, HAVING
   04_poddotazy_cte.sql   IN, EXISTS, NOT EXISTS, ANY, CTE, maxima
   05_typicke_ulohy.sql   ulohy podobne testu
*/

-- Zakladni kostra dotazu:
SELECT sloupce
FROM tabulka
JOIN jina_tabulka ON podminka_spojeni
WHERE podminka_na_radky
GROUP BY sloupce
HAVING podminka_na_skupiny
ORDER BY sloupce;

-- Nejdulezitejsi spojeni:
-- sets.theme_id = themes.id
-- inventories.set_num = sets.set_num
-- inventory_parts.inventory_id = inventories.id
-- inventory_parts.part_num = parts.part_num
-- inventory_parts.color_id = colors.id
-- inventory_minifigs.inventory_id = inventories.id
-- inventory_minifigs.fig_num = minifigs.fig_num
-- parts.part_cat_id = part_categories.id

-- Rychle priklady:

-- Sety vydane od roku 2020.
SELECT set_num, name, year, num_parts
FROM sets
WHERE year >= 2020
ORDER BY year, name;

-- Sety s tematem.
SELECT s.set_num, s.name, t.name AS tema
FROM sets AS s
JOIN themes AS t ON t.id = s.theme_id
WHERE t.name LIKE '%Technic%';

-- Korenova temata.
SELECT id, name
FROM themes
WHERE parent_id IS NULL;

-- Pocet setu podle tematu.
SELECT t.name, COUNT(s.set_num) AS pocet_setu
FROM themes AS t
LEFT JOIN sets AS s ON s.theme_id = t.id
GROUP BY t.id, t.name
ORDER BY pocet_setu DESC;

-- Bezny pocet dilku v inventari.
SELECT i.set_num, SUM(ip.quantity) AS pocet_dilku
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
WHERE ip.is_spare = FALSE
GROUP BY i.set_num;

-- Sety s vice dilky nez prumer.
SELECT set_num, name, num_parts
FROM sets
WHERE num_parts > (SELECT AVG(num_parts) FROM sets);

-- Sety bez inventare.
SELECT s.set_num, s.name
FROM sets AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM inventories AS i
    WHERE i.set_num = s.set_num
);

-- Kontrola pred odevzdanim:
-- 1. Pocitam sety, nebo inventare? Podle toho pouziju DISTINCT.
-- 2. Chci zachovat i zaznamy bez shody? Pouziju LEFT JOIN.
-- 3. Testuji NULL pres IS NULL / IS NOT NULL.
-- 4. Filtruji radky pres WHERE, skupiny pres HAVING.
-- 5. Pri M:N spojeni kontroluji duplicity.
-- 6. set_num, part_num a fig_num jsou texty -> apostrofy.
