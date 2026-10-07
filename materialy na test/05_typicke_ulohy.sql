/* LEGO databaze - typicke ulohy na procviceni */

-- 1) Vypis set_num, jmeno a tema setu vydanych po roce 2015.
SELECT s.set_num, s.name, t.name AS tema
FROM sets AS s
JOIN themes AS t ON t.id = s.theme_id
WHERE s.year > 2015
ORDER BY s.year, s.name;

-- 2) Pro kazde tema vypis pocet setu, ale jen temata s alespon 10 sety.
SELECT t.id, t.name, COUNT(s.set_num) AS pocet
FROM themes AS t
LEFT JOIN sets AS s ON s.theme_id = t.id
GROUP BY t.id, t.name
HAVING COUNT(s.set_num) >= 10
ORDER BY pocet DESC;

-- 3) Vypis sety, ktere maji vice nez 500 beznych dilku.
-- Pocet je v inventari, proto nejdriv seskupim inventory_id.
SELECT i.set_num, i.id AS inventory_id,
       SUM(ip.quantity) AS beznych_dilku
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
WHERE ip.is_spare = FALSE
GROUP BY i.set_num, i.id
HAVING SUM(ip.quantity) > 500
ORDER BY beznych_dilku DESC;

-- 4) Vypis jmena barev, ktere se pouzivaji ve vice nez 100 setech.
SELECT c.name, COUNT(DISTINCT i.set_num) AS pocet_setu
FROM colors AS c
JOIN inventory_parts AS ip ON ip.color_id = c.id
JOIN inventories AS i ON i.id = ip.inventory_id
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT i.set_num) > 100
ORDER BY pocet_setu DESC;

-- 5) Vypis dily z kategorie, jejiz jmeno obsahuje Minifig.
SELECT p.part_num, p.name, pc.name AS kategorie
FROM parts AS p
JOIN part_categories AS pc ON pc.id = p.part_cat_id
WHERE pc.name LIKE '%Minifig%'
ORDER BY p.name;

-- 6) Pro kazdy set vypis pocet ruznych druhu dilku.
SELECT i.set_num, COUNT(DISTINCT ip.part_num) AS druhy_dilku
FROM inventories AS i
LEFT JOIN inventory_parts AS ip ON ip.inventory_id = i.id
GROUP BY i.set_num
ORDER BY druhy_dilku DESC;

-- 7) Vypis sety, ktere maji minifigurku s nazvem obsahujicim Woman.
SELECT DISTINCT i.set_num, s.name, m.name AS minifigurka
FROM inventories AS i
JOIN sets AS s ON s.set_num = i.set_num
JOIN inventory_minifigs AS im ON im.inventory_id = i.id
JOIN minifigs AS m ON m.fig_num = im.fig_num
WHERE m.name LIKE '%Woman%'
ORDER BY i.set_num;

-- 8) Vypis root temata a jejich podtemata.
SELECT rodic.name AS root_tema, potomek.name AS podtema
FROM themes AS rodic
JOIN themes AS potomek ON potomek.parent_id = rodic.id
WHERE rodic.parent_id IS NULL
ORDER BY rodic.name, potomek.name;

-- 9) Pro kazdy typ vztahu dilku spocitej pocet vztahu.
SELECT rel_type, COUNT(*) AS pocet_vztahu
FROM part_relationships
GROUP BY rel_type
ORDER BY rel_type;

-- 10) Vypis dily, ktere jsou child v nejakem vztahu typu R.
SELECT DISTINCT child.part_num, child.name
FROM part_relationships AS pr
JOIN parts AS child ON child.part_num = pr.child_part_num
WHERE pr.rel_type = 'R'
ORDER BY child.part_num;

-- 11) Najdi sety, ktere maji vice dilku nez prumerny set.
SELECT set_num, name, num_parts
FROM sets
WHERE num_parts > (SELECT AVG(num_parts) FROM sets)
ORDER BY num_parts DESC;

-- 12) Najdi sety bez inventare.
SELECT s.set_num, s.name
FROM sets AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM inventories AS i
    WHERE i.set_num = s.set_num
);

-- 13) Pocet nahradnich dilku pro kazdy set.
SELECT i.set_num,
       COALESCE(SUM(ip.quantity) FILTER (WHERE ip.is_spare = TRUE), 0)
           AS nahradnich_dilku
FROM inventories AS i
LEFT JOIN inventory_parts AS ip ON ip.inventory_id = i.id
GROUP BY i.set_num
ORDER BY nahradnich_dilku DESC;

-- 14) Kontrola duplicity inventory verzi: sety s vice nez jednim inventarem.
SELECT set_num, COUNT(*) AS pocet_inventaru
FROM inventories
GROUP BY set_num
HAVING COUNT(*) > 1
ORDER BY pocet_inventaru DESC;

-- 15) Dulezita kontrola: pokud chci pocet setu, nepocitam radky dilku.
SELECT COUNT(DISTINCT i.set_num) AS pocet_setu
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id;
