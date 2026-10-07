/*
1 uloha:
Zadani: Pro kazdy film vypiste, kolik v nem hraje hercu a v kolika kategoriich se nachazi.

Napoveda: Pozor na kartezsky soucin pri spojeni dvou vazebnich
 tabulek najednou - zkuste misto toho dva samostatne skalarni poddotazy v SELECT.
*/


SELECT F.film_id, F.title,
    (SELECT COUNT(actor_id)
     FROM film_actor FA
     WHERE FA.film_id = F.film_id) AS pocet_hercu,
    (SELECT COUNT(*)
     FROM film_category FC
    WHERE FC.film_id = F.film_id) AS pocet_kategorii
FROM film F;

/*
uloha 2:
Zadani: Pro kazdeho zakaznika vypiste pocet vypujcek trvajicich mene nez 5 dni a pocet vypujcek trvajicich mene nez 7 dni.

Napoveda: Pouzijte dva nezavisle korelovane poddotazy v SELECT.
Podminku na dobu trvani dejte dovnitr poddotazu, ne do vnejsiho WHERE.
*/

SELECT customer_id,
(SELECT COUNT(*)
 FROM rental R
 WHERE R.customer_id = C.customer_id
     AND EXTRACT(DAY FROM COALESCE(R.return_date, NOW()) - R.rental_date) < 5) AS mene_nez5,
(SELECT COUNT(*)
 FROM rental R
 WHERE R.customer_id = C.customer_id
     AND EXTRACT(DAY FROM COALESCE(R.return_date, NOW()) - R.rental_date) < 7) AS mene_nez7
FROM customer C;
