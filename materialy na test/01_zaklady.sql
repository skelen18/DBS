/* LEGO databaze - zaklady SELECTu a filtry */

-- Rychla kontrola obsahu tabulky.
SELECT *
FROM sets;

-- Vyberu jen sloupce, ktere potrebuju.
SELECT set_num, name, year, num_parts
FROM sets
ORDER BY year, name;

-- Filtry cisel a textu.
SELECT set_num, name, year, num_parts
FROM sets
WHERE year >= 2020
  AND num_parts > 1000
ORDER BY num_parts DESC;

-- IN pro vice povolenych hodnot.
SELECT set_num, name, year
FROM sets
WHERE year IN (2018, 2019, 2020)
ORDER BY year, name;

-- BETWEEN je vcetne obou hranic.
SELECT set_num, name, num_parts
FROM sets
WHERE num_parts BETWEEN 10 AND 100
ORDER BY num_parts;

-- LIKE: % je libovolne mnozstvi znaku, _ je jeden znak.
SELECT set_num, name
FROM sets
WHERE name LIKE '%Castle%';

SELECT part_num, name
FROM parts
WHERE name LIKE 'Helmet%';

-- DISTINCT odstrani duplicity.
SELECT DISTINCT year
FROM sets
ORDER BY year;

SELECT DISTINCT part_material
FROM parts
WHERE part_material IS NOT NULL
ORDER BY part_material;

-- NULL se testuje pres IS NULL, ne pres = NULL.
SELECT element_id, part_num, design_id
FROM elements
WHERE design_id IS NULL;

SELECT element_id, part_num, design_id
FROM elements
WHERE design_id IS NOT NULL;

-- COALESCE nahradi NULL textem.
SELECT name, COALESCE(part_material, 'nezadano') AS material
FROM parts;

-- Prevod boolean hodnot.
SELECT part_num, quantity, is_spare
FROM inventory_parts
WHERE is_spare = FALSE;

SELECT part_num, quantity, is_spare
FROM inventory_parts
WHERE is_spare = TRUE;

-- Spocitany sloupec a alias.
SELECT set_num, name,
       num_parts * 2 AS dvojnasobek_dilku
FROM sets
WHERE num_parts > 0;

-- Textove spojeni v PostgreSQL.
SELECT set_num || ' - ' || name AS stavebnice
FROM sets
ORDER BY stavebnice;

-- Poradi casti dotazu je vzdy SELECT FROM WHERE ORDER BY.
