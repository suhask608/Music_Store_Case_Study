------------------------------------------------------------------------- MUSIC STORE DATA ANALYSIS----------------------------------------------------------------------------
create database music;
use music;

-- Question Set-1  --
# Who is the senior most employee based on job title?
select concat(first_name,+" ",+last_name) as name, title from employee
order by levels desc limit 1;

# Which countries have the most Invoices?
select billing_country, count(distinct invoice_id) as invoice_count from invoice
group by billing_country
order by invoice_count desc;

# What are top 3 values of total invoice?
select distinct invoice_id, sum(total) as total_invoice
from invoice
group by invoice_id
order by total_invoice desc limit 3;

# Which city has the best customers? 
select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc limit 1;

# Who is the best customer? 
select i.customer_id, sum(i.total) as total_invoice, concat(c.first_name,+" ",+c.last_name) as name
from invoice i inner join customer c
on i.customer_id = c.customer_id
group by i.customer_id, c.first_name, c.last_name
order by total_invoice desc limit 1;

-- Question Set-2 --
# Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select Distinct concat(c.first_name,+" ",+c.last_name) as name, c.email, genre.name 
from customer c
inner join invoice ON c.customer_id = invoice.customer_id
inner join invoice_line ON invoice_line.invoice_id = invoice.invoice_id
inner join track ON track.track_id = invoice_line.track_id
inner join genre on genre.genre_id = track.genre_id
where genre.name LIKE "Rock"
order by c.email;

# Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.
select artist.name, count(distinct track.track_id) as track_count
from track 
inner join album ON track.album_id = album.album_id
inner join artist ON artist.artist_id = album.album_id
inner join genre ON genre.genre_id = track.genre_id
where genre.name LIKE "Rock"
group by artist.name
order by track_count desc limit 10;

# Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

-- Question Set-3 --
# Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.
select  DISTINCT customer.first_name, customer.last_name, artist.name, sum(invoice_line.unit_price) as total_spent
from customer 
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on track.track_id = invoice_line.track_id
inner join album on album.album_id = track.album_id
inner join artist on artist.artist_id = album.artist_id
group by customer.first_name, customer.last_name, artist.name
order by total_spent desc;

# 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

# Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent.  for countries where the top amount spent is shared, provide all customers who spent this amount.
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;




