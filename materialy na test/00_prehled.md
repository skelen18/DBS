# LEGO databaze - rychly prehled

## Tabulky

- `sets`: stavebnice; `set_num`, `name`, `year`, `theme_id`, `num_parts`
- `themes`: temata; `id`, `name`, `parent_id`
- `inventories`: verze inventare; `id`, `version`, `set_num`
- `inventory_sets`: dalsi stavebnice v inventari; `inventory_id`, `set_num`, `quantity`
- `minifigs`: katalog minifigurek; `fig_num`, `name`, `num_parts`
- `inventory_minifigs`: minifigurky v inventari; `inventory_id`, `fig_num`, `quantity`
- `part_categories`: kategorie dilku; `id`, `name`
- `parts`: dilky; `part_num`, `name`, `part_cat_id`, `part_material`
- `inventory_parts`: dilky v inventari; `inventory_id`, `part_num`, `color_id`, `quantity`, `is_spare`
- `colors`: barvy; `id`, `name`, `rgb`, `is_trans`, `num_parts`, `num_sets`, `y1`, `y2`
- `elements`: barevne/designove varianty; `element_id`, `part_num`, `color_id`, `design_id`
- `part_relationships`: vztahy dilku; `rel_type`, `child_part_num`, `parent_part_num`

## Nejdulezitejsi cesty pro JOIN

```text
sets -> themes                 s.theme_id = t.id
sets -> inventories            s.set_num = i.set_num
inventories -> inventory_parts i.id = ip.inventory_id
inventory_parts -> parts      ip.part_num = p.part_num
inventory_parts -> colors     ip.color_id = c.id
inventories -> inventory_minifigs i.id = im.inventory_id
inventory_minifigs -> minifigs im.fig_num = m.fig_num
parts -> part_categories      p.part_cat_id = pc.id
part_relationships -> parts   child_part_num / parent_part_num = parts.part_num
```

## Veci, na ktere si dat pozor

- `set_num`, `part_num` a `fig_num` jsou texty, proto se pisi do apostrofu.
- Jeden set muze mit vice inventaru. Kdyz chci pocitat sety, casto potrebuju `COUNT(DISTINCT s.set_num)`.
- `inventory_parts` neni jen seznam dilku: stejny dil muze byt v ruzne barve a muze byt bezny nebo nahradni.
- `is_spare = TRUE` znamena nahradni dil, `FALSE` bezny dil.
- `themes` je tabulka sama se sebou: rodic je druhy alias tabulky.
- `inventory_sets` obsahuje stavebnice vlozene do jineho inventare.
- `elements` spojovat s `inventory_parts` pres obe hodnoty: `part_num` i `color_id`.
- Pri spojeni pres vazebni tabulku se mohou radky nasobit. Pomaha `DISTINCT` nebo spravna agregace.

## Jak zacit kazde zadani

```sql
SELECT ...
FROM ...
JOIN ... ON ...
WHERE ...
GROUP BY ...
HAVING ...
ORDER BY ...;
```

Nejdriv si podtrhnu, co mam vypsat, potom si nakreslim cestu mezi tabulkami. Teprve pak pisu podminky.

## Temata

- zaklady a filtry: `01_zaklady.sql`
- JOINy a vztahy: `02_joiny.sql`
- COUNT, SUM a GROUP BY: `03_agregace.sql`
- IN, EXISTS, CTE a maxima: `04_poddotazy_cte.sql`
- ulohy podobne testu: `05_typicke_ulohy.sql`
