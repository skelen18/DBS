/* LEGO databaze - poddotazy, EXISTS, maxima a CTE */

-- Sety s vice dilky, nez je prumer vsech setu.
SELECT set_num, name, num_parts
FROM sets
WHERE num_parts > (SELECT AVG(num_parts) FROM sets)
ORDER BY num_parts DESC;

-- Sety, ktere patri do temata se slovem Technic.
SELECT set_num, name
FROM sets
WHERE theme_id IN (
    SELECT id
    FROM themes
    WHERE name LIKE '%Technic%'
);

-- Stejna podminka pomoci EXISTS.
SELECT s.set_num, s.name
FROM sets AS s
WHERE EXISTS (
    SELECT 1
    FROM themes AS t
    WHERE t.id = s.theme_id
      AND t.name LIKE '%Technic%'
);

-- Temata, do kterych nespada zadny set.
SELECT t.id, t.name
FROM themes AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM sets AS s
    WHERE s.theme_id = t.id
);

-- Sety, ktere maji alespon jeden bezny dil z dane barvy.
SELECT DISTINCT s.set_num, s.name
FROM sets AS s
WHERE EXISTS (
    SELECT 1
    FROM inventories AS i
    JOIN inventory_parts AS ip ON ip.inventory_id = i.id
    JOIN colors AS c ON c.id = ip.color_id
    WHERE i.set_num = s.set_num
      AND ip.is_spare = FALSE
      AND c.name = 'Red'
);

-- Sety, ktere nemaji zadnou minifigurku.
SELECT s.set_num, s.name
FROM sets AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM inventories AS i
    JOIN inventory_minifigs AS im ON im.inventory_id = i.id
    WHERE i.set_num = s.set_num
);

-- Nejvetsi set nebo sety. ALL zachova shodu pri remize.
SELECT set_num, name, num_parts
FROM sets AS s
WHERE s.num_parts >= ALL (
    SELECT num_parts
    FROM sets
);

-- Nejvetsi set nebo sety pres MAX.
SELECT set_num, name, num_parts
FROM sets
WHERE num_parts = (SELECT MAX(num_parts) FROM sets);

-- CTE: nejdriv si spocitam pocet dilku v inventari, pak ho pouziju.
WITH pocty AS (
    SELECT i.set_num,
           i.id AS inventory_id,
           SUM(ip.quantity) AS pocet_kusu
    FROM inventories AS i
    JOIN inventory_parts AS ip ON ip.inventory_id = i.id
    WHERE ip.is_spare = FALSE
    GROUP BY i.set_num, i.id
)
SELECT *
FROM pocty
WHERE pocet_kusu = (SELECT MAX(pocet_kusu) FROM pocty);

-- CTE pro temata, ktera maji nadprumerny pocet setu.
WITH pocty AS (
    SELECT t.id, t.name, COUNT(s.set_num) AS pocet_setu
    FROM themes AS t
    LEFT JOIN sets AS s ON s.theme_id = t.id
    GROUP BY t.id, t.name
)
SELECT *
FROM pocty
WHERE pocet_setu > (SELECT AVG(pocet_setu) FROM pocty)
ORDER BY pocet_setu DESC;

-- ANY: podminka plati proti alespon jedne hodnote z poddotazu.
-- Sety s vice dilky nez alespon jeden set tematu Technic.
SELECT s.set_num, s.name, s.num_parts
FROM sets AS s
WHERE s.num_parts > ANY (
    SELECT s2.num_parts
    FROM sets AS s2
    JOIN themes AS t ON t.id = s2.theme_id
    WHERE t.name LIKE '%Technic%'
);

-- NOT IN muze byt problem, pokud poddotaz vrati NULL.
-- Pro "neexistuje" je obvykle lepsi NOT EXISTS.
