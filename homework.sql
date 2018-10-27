USE sakila;

-- DESCRIBE actor 

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
	FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name 
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";
      
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%li%"
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country, country_id
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in the table actor named description and 
-- use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS"; 

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- UPDATE actor
-- SET first_name = 
-- CASE WHEN first_name = "HARPO" 
-- THEN "GROUCHO"
-- END;  

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
DESCRIBE staff;
DESCRIBE address;

SELECT first_name, last_name, address
FROM address
JOIN staff
USING (address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
DESCRIBE staff;
DESCRIBE payment;

SELECT staff.staff_id, SUM(amount), first_name, last_name, payment_date
FROM payment
INNER JOIN staff 
ON payment.staff_id = staff.staff_id
WHERE payment_date LIKE "2005-08-%%"
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
DESCRIBE film;
DESCRIBE film_actor;

SELECT title, film_actor.film_id, count(actor_id)
FROM film_actor
INNER JOIN film
ON (film_actor.film_id = film.film_id)
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;
SELECT * FROM film;

SELECT count(film.film_id), title, inventory.store_id
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible"
GROUP BY store_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- [Total amount paid](Images/total_payment.png)

SELECT customer.customer_id, first_name, last_name, sum(amount)
FROM customer
INNER JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY last_name DESC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
 	FROM film
 	WHERE title LIKE "Q%"
    OR title LIKE "K%"
	AND language_id = 1;


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT customer_list.id, customer_list.name, customer.email, customer_list.country
FROM customer_list
INNER JOIN customer
ON customer_list.id = customer.customer_id
WHERE country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT * FROM film_list
WHERE (category = "family")
AND (rating = "PG" 
OR rating = "G");

-- 7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, film.title, count(rental.rental_date)
FROM rental
INNER JOIN inventory
INNER JOIN film
ON (inventory.film_id = film.film_id)
AND (inventory.inventory_id = rental.inventory_id)
GROUP BY title
ORDER BY count(rental.rental_date) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- So first I did this one, which returned a very reasonable result since both Canadian and Australian curreny are both technically dollars
-- But I know how shitty these homework assignments are so I figured they wanted something else but weren't asking for it clearly
-- SELECT * FROM sales_by_store;

-- So then I found this one on the internet and it gives a dollar sign, which I don't know if that's what the question wanted or not, but here ya go
SELECT store, manager, concat('$', format(total_sales, 2))
FROM sales_by_store
GROUP BY 1;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT SID, city, country FROM staff_list;
-- Don't tell me this is wrong just because it's not ridiculously complicated. This works. It answers the question. I hate everything.

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT film_list.category, sum(film_list.price), count(rental.rental_date)
FROM film_list
INNER JOIN rental
INNER JOIN inventory
ON (inventory.inventory_id = rental.inventory_id)
AND (inventory.film_id = film_list.FID)
GROUP BY category
ORDER BY sum(film_list.price) DESC;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Copies_Available AS
SELECT title, (SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id ) AS 'Number of Copies'
FROM film;


-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW Copies_Available;

SELECT * FROM Copies_Available;
-- Again, I'm not sure what the question is actually asking for, so I did both.

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Copies_Available;