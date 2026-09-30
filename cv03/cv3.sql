/*SNAD JSEM UDELLA VSE, melo by vse nejak samostatne jit, dost jsem opisoval, ale po svem
aj jsem neco napsal sam*/


--COUNT procviceni
SELECT 
    count (*) as pocet_r,
    count(1) as pocet_r2,
    count(original_language_id) as pocet_ol,
    count(NULL) as count_null,
    count(DISTINCT original_language_id) as dist_pocet_ol

FROM film f;

SELECT
    original_language_id
FROM film f
JOIN language 
    ON language.language_id = f.original_language_id
WHERE original_language_id IS NOT NULL
ORDER BY 1;


--SUM procviceni
SELECT 
    f.rating,
    sum(length)/60/24 as soucet_delek,
    min(length) as nejkratsi,
    max(length) as nejdelsi,
    avg(length) as prumer
FROM film f
WHERE f.length>60
GROUP BY f.rating
HAVING sum(length)/60/24 > 14
ORDER BY 1;

SELECT DISTINCT f.rating, f.length
FROM film f
ORDER BY 1;


/*1. ukol vypište počty filmů pro jednotlive delky (atribut length) */
SELECT f.length, count(1)
FROM film f
GROUP BY f.length
ORDER BY f.length;


/*2. ukol - pro kazde jmeno zakaznika vypiste pocet zakazniku s timto jmenem*/
SELECT c.first_name,
    count(c.first_name)
FROM customer c
GROUP BY c.first_name
-- kdyz napiseme aj having, tak to zobrazi pouze duplicitni jmena
HAVING count(c.first_name) > 1
--kdyz dame jen orderby bez having, tak to zobrazi celkovy pocet duplicitnich jmen
ORDER BY COUNT(c.first_name) DESC;


/*3. ukol vypište součty všch plateb za jednotlive roky a mesice
vysledek usporadejte podle roku a mesice */
SELECT
    --extract dela z data jen rok a mesic
    EXTRACT(YEAR FROM payment_date) AS rok,
    EXTRACT(MONTH FROM payment_date) AS mesic,
    SUM(amount) AS soucet_plateb
FROM payment as p
GROUP BY 
    EXTRACT(YEAR FROM payment_date),
    EXTRACT(MONTH FROM payment_date)
ORDER BY rok ASC, mesic ASC;


/*4. ukol vypiste klasifikace filmu (atribut rating), jejich delka je mensi nez 50 
a velkova delka takovych filmu v dane klasifikaci je vetsi nez 250 minut.
vysledek seradte sestupne podle abecedy*/
SELECT f. rating, 
    SUM(f.length) AS soucet
FROM film f
WHERE f.length < 50
GROUP BY f.rating
HAVING SUM(f.length) > 250
ORDER BY f.rating DESC;


/*6. ukol vypiste pro jednotlive zakazniky (jejich ID, jmeno a prijmeni)
pocty ruznych filmu ktere si vypujcili */
SELECT c.customer_id, c.first_name, c.last_name, count(DISTINCT f.film_id)
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
RIGHT JOIN customer c ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING count(f.film_id) = 0;


/*7. pro kazdeho herce vypiste v kolika ruznych kategorii se vyskytuje a seradit podle poctu kategorii*/
SELECT a.actor_id, a.first_name, a.last_name, count(DISTINCT fc.category_id) as pocet_kategorii
FROM actor a
LEFT JOIN film_actor as fa 
    ON fa.actor_id = a.actor_id
LEFT JOIN film f 
    ON f.film_id = fa.film_id
LEFT JOIN film_category fc 
    ON fc.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY pocet_kategorii ASC;

/*8. UKOL pro vsechny zakazniky z polska vypiste , do kolika ruznych kategorii spadaji a  vypujcili*/
SELECT cu.customer_id, cu.first_name, cu.last_name, count(DISTINCT fc.category_id)
FROM country co
JOIN city ci
    ON ci.country_id = co.country_id
JOIN address a
    ON a.city_id = ci.city_id
JOIN customer cu
    ON cu.address_id = a.address_id
JOIN rental r
    ON r.customer_id = cu.customer_id
JOIN inventory i
    ON i.inventory_id = r.inventory_id
JOIN film f
    ON f.film_id = i.film_id
JOIN film_category fc
    ON fc.film_id = f.film_id
WHERE co.country = 'Poland'
GROUP BY cu.customer_id, cu.first_name, cu.last_name