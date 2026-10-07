/* LEGO databaze - JOINy a vazby mezi tabulkami */

-- Set a jeho tema.
SELECT s.set_num, s.name AS stavebnice, t.name AS tema
FROM sets AS s
JOIN themes AS t ON t.id = s.theme_id
ORDER BY t.name, s.name;

-- I temata bez setu: zacnu u themes a pouziju LEFT JOIN.
SELECT t.id, t.name, COUNT(s.set_num) AS pocet_stavebnic
FROM themes AS t
LEFT JOIN sets AS s ON s.theme_id = t.id
GROUP BY t.id, t.name
ORDER BY pocet_stavebnic DESC, t.name;

-- Rodic a potomek v tabulce themes. Je to self JOIN.
SELECT potomek.name AS podtema,
       rodic.name AS rodicovske_tema
FROM themes AS potomek
JOIN themes AS rodic ON potomek.parent_id = rodic.id
ORDER BY rodic.name, potomek.name;

-- Korenova temata nemaji rodice.
SELECT id, name
FROM themes
WHERE parent_id IS NULL
ORDER BY name;

-- Set -> inventory. Jeden set muze mit vice verzi inventare.
SELECT s.set_num, s.name, i.id AS inventory_id, i.version
FROM sets AS s
JOIN inventories AS i ON i.set_num = s.set_num
ORDER BY s.set_num, i.version;

-- Ktere sety jsou uvnitr inventare konkretniho setu.
SELECT i.set_num AS hlavni_set,
       ins.set_num AS vlozeny_set,
       ins.quantity,
       s.name
FROM inventories AS i
JOIN inventory_sets AS ins ON ins.inventory_id = i.id
JOIN sets AS s ON s.set_num = ins.set_num
WHERE i.set_num = '66214-1';

-- Dilky konkretniho setu. FALSE = bezne, TRUE = nahradni.
SELECT i.set_num, p.part_num, p.name, ip.quantity, ip.is_spare
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
JOIN parts AS p ON p.part_num = ip.part_num
WHERE i.set_num = '66214-1'
ORDER BY p.name;

-- Dilky spolu s barvou.
SELECT i.set_num, p.name AS dil,
       c.name AS barva, ip.quantity, ip.is_spare
FROM inventories AS i
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
JOIN parts AS p ON p.part_num = ip.part_num
JOIN colors AS c ON c.id = ip.color_id
WHERE i.set_num = '66214-1';

-- Dilky a jejich kategorie.
SELECT p.part_num, p.name, pc.name AS kategorie
FROM parts AS p
LEFT JOIN part_categories AS pc ON pc.id = p.part_cat_id
ORDER BY pc.name, p.name;

-- Minifigurky v setu.
SELECT i.set_num, m.fig_num, m.name, im.quantity
FROM inventories AS i
JOIN inventory_minifigs AS im ON im.inventory_id = i.id
JOIN minifigs AS m ON m.fig_num = im.fig_num
WHERE i.set_num = '66214-1';

-- Pozor na elements: propojeni musi pouzit part_num i color_id.
SELECT e.element_id, p.name AS dil, c.name AS barva, e.design_id
FROM elements AS e
JOIN parts AS p ON p.part_num = e.part_num
JOIN colors AS c ON c.id = e.color_id;

-- Vztahy dilku: stejna tabulka parts je zde dvakrat.
SELECT pr.rel_type,
       child.part_num AS child_part,
       child.name AS child_name,
       parent.part_num AS parent_part,
       parent.name AS parent_name
FROM part_relationships AS pr
JOIN parts AS child ON child.part_num = pr.child_part_num
JOIN parts AS parent ON parent.part_num = pr.parent_part_num
ORDER BY pr.rel_type, child.part_num;

-- Kdyz hledam jen sety, DISTINCT odstrani opakovani pres inventare/dilky.
SELECT DISTINCT s.set_num, s.name
FROM sets AS s
JOIN inventories AS i ON i.set_num = s.set_num
JOIN inventory_parts AS ip ON ip.inventory_id = i.id
JOIN colors AS c ON c.id = ip.color_id
WHERE c.name = 'Red';
