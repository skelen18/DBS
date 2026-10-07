
/*ukol 1, idk co to bylo, nestihl jsem */
SELECT film_id, title
FROM film F
WHERE film_id IN (
    SELECT film_id
    FROM film_actor
    WHERE actor_id = 1
);



SELECT film_id, title
FROM film F
WHERE EXISTS(
    SELECT film_id
    FROM film_actor
    WHERE actor_id = 1 AND F.film_id=film_actor.film_id
)

/*uloha 3: 
vypiste id a NAZVY FILMU, VE KTERYCH HRAL HEREC S id = 1 ZAROVEN S HERCEM S ID=10 
dal nevim, jelikoz to dela moc rychle
*/

SELECT film_id, title
FROM film F
WHERE EXISTS(
    SELECT film_id
    FROM film_actor
    WHERE actor_id = 1 AND F.film_id=film_actor.film_id
)
AND EXISTS(
    SELECT film_id
    FROM film_actor
    WHERE actor_id = 10 AND F.film_id=film_actor.film_id
)


/*
uloha 4:
vypiste ID a nazvy filmu, ve kterych hral herec s ID = 1 nebo herec s ID = 10.

Napoveda: Jde o sjednoceni dvou mnozin - zkuste IN 
s podminkou OR uvnitr poddotazu, nebo JOIN s DISTINCT.
*/

SELECT film_id, title
FROM film F
WHERE EXISTS(
    SELECT film_id
    FROM film_actor
    WHERE (actor_id = 1 OR actor_id = 10) AND F.film_id=film_actor.film_id
)

SELECT DISTINCT F.film_id, F.title
FROM film F
JOIN film_actor FA ON F.film_id = FA.film_id
WHERE FA.actor_id IN (1, 10)
ORDER BY F.film_id;


/*
uloha 5:
Zadani: Vypiste ID filmu, ve kterych nehral herec s ID = 1.
Napoveda: Pozor na past s operatorem != - jde o rozdil mnozin, pouzijte NOT IN nebo NOT EXISTS.
*/

SELECT film_id, title
FROM film F
WHERE NOT EXISTS(
    SELECT film_id
    FROM film_actor
    WHERE actor_id = 1 AND F.film_id=film_actor.film_id
)


/*
uloha 7:
Vypiste ID a nazvy filmu, ve kterych hral herec PENELOPE GUINESS zaroven s hercem CHRISTIAN GABLE.

Napoveda: Stejny princip jako uloha 3, ale herce musite dohledat podle jmena pres JOIN s tabulkou actor.
*/
SELECT film_id, title
FROM film F
WHERE EXISTS(
    SELECT film_id
    FROM film_actor FA
    JOIN actor A ON FA.actor_id = A.actor_id
    WHERE A.first_name = 'PENELOPE' 
    AND A.last_name = 'GUINESS' 
    AND F.film_id=FA.film_id
)
AND EXISTS(
    SELECT film_id
    FROM film_actor FA
    JOIN actor A ON FA.actor_id = A.actor_id
    WHERE A.first_name = 'CHRISTIAN' 
    AND A.last_name = 'GABLE' 
    AND F.film_id=FA.film_id
)


/*
uloha 13:
Zadani: Vypiste nazvy filmu, ktere jsou kratsi nez nejaky film, ve kterem hraje BURT POSEY.

Napoveda: Zkuste kvantifikator ANY/SOME, nebo EXISTS s porovnanim delek filmu.
*/

SELECT film_id, title
FROM film F
where Exists(
    SELECT film_id
    FROM film_actor FA
    JOIN actor A ON FA.actor_id = A.actor_id
    WHERE A.first_name = 'BURT' 
    AND A.last_name = 'POSEY' 
    AND F.length < (SELECT length FROM film WHERE film_id = FA.film_id)
)
