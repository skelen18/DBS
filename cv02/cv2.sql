/*
shift + alt + a zakomentuje oznacene radky
shift + enter spusti query oznacene v editoru
DISTINCT znamena ze se nebudou opakovat stejne hodnoty
LEFT JOIN znamena ze se vezme vse z leve tabulky a pokud neni shoda v prave tabulce tak se doplni NULL
*/

UPDATE film SET description = NULL WHERE film_id <= 10;

/*1. ukol vypis filmu s delkou > 120 a popisem NULL */
SELECT f.title, f.description
FROM public.film as f 
WHERE f.length > 120 and f.description IS /*NOT*/NULL

/*2. ukol spojeni */
SELECT f.title || '-' || COALESCE(f.description, 'no description', f.title) as long_name
FROM public.film as f 
WHERE f.length > 120 and f.description IS NULL

/*3. ukol vypis adresy a dalsich veci idk */
SELECT address, district, a.city_id, c.city
FROM public.address as a

JOIN public.city as c 
    ON a.city_id = c.city_id
JOIN public.country as cc 
    ON cc.country_id = c.country_id
JOIN public.store as s
    ON a.address_id = s.address_id

/*4. ukol spojit se zakaznikem a vypsat zeme a filmy dle jeho pujcek */
SELECT DISTINCT cc.country, f.title
FROM public.address as a

JOIN public.city as c 
    ON a.city_id = c.city_id
JOIN public.country as cc 
    ON cc.country_id = c.country_id
JOIN public.customer as cu
    ON cu.address_id = a.address_id
JOIN public.rental as r
    ON r.customer_id = cu.customer_id
JOIN public.inventory as i
    ON i.inventory_id = r.inventory_id
JOIN public.film as f
    ON f.film_id = i.film_id
WHERE f.length > 120 and extract(year from r.rental_date) = 2005
ORDER BY 1

/*5. ukol vypsani filmu podle kategorie */
SELECT DISTINCT f.film_id, f.title, c.name 
FROM public.film as f
JOIN public.film_category as fc 
    ON f.film_id = fc.film_id
JOIN  public.category as c
    ON c.category_id = fc.category_id
WHERE c.name in ('Comedy', 'Drama')
ORDER BY f.title

/*6. ukol vypis pujcek bez platby a anebo vracene */
SELECT r.rental_id, r.rental_date, p.payment_date, r.return_date
FROM public.rental as r
left JOIN public.payment as p
    ON r.rental_id = p.rental_id
WHERE p.payment_id IS NULL AND r.return_date IS NOT NULL

/*7. ukol vypis filmu a jejich jazyku konkrétního originálu*/
SELECT f.film_id, l.language_id, l.name, ol.name as OLNAME
FROM public.film as f
JOIN public.language as l
    ON f.language_id = l.language_id
left JOIN public.language as ol
    ON ol.language_id = f.original_language_id AND OL.name = 'English'
--WHERE ol.name = 'English' or ol.name IS NULL

/*8. ukol vypis poctu filmu podle ratingu a vsech unikatnich hodnot*/
SELECT COUNT (1), COUNT(NULL), COUNT(f.film_id), count(DISTINCT f.film_id), COUNT(DISTINCT f.title),COUNT(DISTINCT f.rating)
from public.film as f

--SELECT DISTINCT f.rating 
--from public.film as f
--z nejakeho duvodu to nejde asi syntax erorr ale uz neni cas