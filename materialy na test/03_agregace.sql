/* LEGO databaze - COUNT, SUM, GROUP BY, HAVING */

-- Jedna souhrnna radka.
SELECT COUNT(*) AS pocet_setu,
       MIN(year) AS prvni_rok,
       MAX(year) AS posledni_rok,
       AVG(num_parts) AS prumerny_pocet_dilku
FROM sets;

-- COUNT(*) pocita radky. COUNT(sloupec) nepocita NULL.
SELECT COUNT(*) AS vsechny_radky,
       COUNT(parent_id) AS temata_s_rodicem,
       COUNT(DISTINCT parent_id) AS ruznych_rodicu
FROM themes;

-- Pocet setu podle roku.
SELECT year, COUNT(*) AS pocet_setu
FROM sets
GROUP BY year
ORDER BY year;

-- Jen roky s vice nez 100 sety.
SELECT year, COUNT(*) AS pocet_setu
FROM sets
GROUP BY year
HAVING COUNT(*) > 100
ORDER BY pocet_setu DESC;

-- Pocet setu podle tematu.
SELECT t.id, t.name, COUNT(s.set_num) AS pocet_setu
FROM themes AS t
LEFT JOIN sets AS s ON s.theme_id = t.id
GROUP BY t.id, t.name
HAVING COUNT(s.set_num) > 0
ORDER BY pocet_setu DESC, t.name;

-- Suma beznych a nahradnich dilku pro kazdy inventar.
SELECT inventory_id,
       SUM(quantity) FILTER (WHERE is_spare = FALSE) AS bezne_dilky,
       SUM(quantity) FILTER (WHERE is_spare = TRUE) AS nahradni_dilky
FROM inventory_parts
GROUP BY inventory_id
ORDER BY inventory_id;

-- Stejne bez FILTER pomoci CASE.
SELECT inventory_id,
       SUM(CASE WHEN is_spare = FALSE THEN quantity ELSE 0 END) AS bezne,
       SUM(CASE WHEN is_spare = TRUE THEN quantity ELSE 0 END) AS nahradni
FROM inventory_parts
GROUP BY inventory_id;

-- Kolik ruznych barev se pouziva v kazdem setu.
SELECT i.set_num,
       COUNT(DISTINCT ip.color_id) AS pocet_barev,
       COUNT(DISTINCT ip.part_num) AS pocet_druhu_dilku,
       SUM(ip.quantity) AS celkem_kusu
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
GROUP BY i.set_num
ORDER BY pocet_druhu_dilku DESC;

-- Pocet ruznych setu, ktere pouzivaji barvu.
SELECT c.id, c.name,
       COUNT(DISTINCT i.set_num) AS pocet_setu
FROM colors AS c
JOIN inventory_parts AS ip ON ip.color_id = c.id
JOIN inventories AS i ON i.id = ip.inventory_id
GROUP BY c.id, c.name
ORDER BY pocet_setu DESC;

-- Kategorie dilku a pocet dilku v kazde kategorii.
SELECT pc.id, pc.name, COUNT(p.part_num) AS pocet_dilku
FROM part_categories AS pc
LEFT JOIN parts AS p ON p.part_cat_id = pc.id
GROUP BY pc.id, pc.name
ORDER BY pocet_dilku DESC;

-- Kategorie, ktere maji alespon 100 dilku.
SELECT pc.name, COUNT(p.part_num) AS pocet_dilku
FROM part_categories AS pc
JOIN parts AS p ON p.part_cat_id = pc.id
GROUP BY pc.id, pc.name
HAVING COUNT(p.part_num) >= 100
ORDER BY pocet_dilku DESC;

-- Kolik ruznych minifigurek se objevuje v jednotlivych letech vydani setu.
SELECT s.year, COUNT(DISTINCT im.fig_num) AS ruznych_minifigurek
FROM sets AS s
JOIN inventories AS i ON i.set_num = s.set_num
JOIN inventory_minifigs AS im ON im.inventory_id = i.id
GROUP BY s.year
ORDER BY s.year;

-- V GROUP BY musi byt kazdy neagregovany sloupec ze SELECTu.
-- WHERE filtruje radky pred GROUP BY, HAVING filtruje cele skupiny.
