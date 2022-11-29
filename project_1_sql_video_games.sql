SELECT *FROM games.game_sales;
SELECT *FROM games.game_reviews;
--importando tabela game_sales
COPY games.game_sales
FROM 'C:\agnis_projetos\game_sales_table.csv'
delimiter ','
csv header;
--importando tabela game_reviews
COPY games.game_reviews
FROM 'C:\agnis_projetos\game_reviews_table.csv'
delimiter ','
csv header;

--Top 10 sellings video games
SELECT * FROM games.game_sales
ORDER BY game_sales.total_shipped DESC
LIMIT 10;

--count missing review scores
SELECT COUNT (game_sales.name) AS missing_scores
FROM games.game_sales
LEFT JOIN games.game_reviews
	ON game_sales.name=game_reviews.name
WHERE game_reviews.critic_score IS NULL AND
	  game_reviews.user_score IS NULL

--years that video games critics loved
SELECT game_sales.year, ROUND(AVG(game_reviews.critic_score),2)AS critic_score,COUNT(game_reviews.critic_score) AS critic_numb
FROM games.game_sales
LEFT JOIN games.game_reviews
	ON game_sales.name=game_reviews.name
GROUP BY game_sales.year
ORDER BY critic_score DESC
LIMIT 10;
 
--round numbers for average seems suspicius.
--The 1982 value looks especially fishy for an average (9.00)
-- this happens probably because there weren't a lot of videos realeased in our dataset in certain years

-- So,let's limit our data set to games with >4 critic_score
SELECT game_sales.year, ROUND(AVG(game_reviews.critic_score),2)AS critic_score,COUNT(game_reviews.critic_score) AS critic_numb
FROM games.game_sales
LEFT JOIN games.game_reviews
	ON game_sales.name=game_reviews.name
GROUP BY game_sales.year
HAVING COUNT(game_reviews.critic_score)>4
ORDER BY critic_score DESC
LIMIT 10;

-- years video games players loved
SELECT game_sales.year, ROUND(AVG(game_reviews.user_score),2)AS player_avg
FROM games.game_sales
LEFT JOIN games.game_reviews
	ON game_sales.name=game_reviews.name
GROUP BY game_sales.year
HAVING COUNT(game_reviews.user_score)>4
ORDER BY player_avg DESC
LIMIT 10;

--Years that both players and critics loved
SELECT
	ct.year,
	ROUND(AVG(ct.critic_score),2)AS critic_score,
	ROUND(AVG(ut.player_avg),2) AS player_score
FROM 
		(SELECT game_sales.year, ROUND(AVG(game_reviews.critic_score),2)AS critic_score,COUNT(game_reviews.critic_score) AS critic_numb
		FROM games.game_sales
		LEFT JOIN games.game_reviews
			ON game_sales.name=game_reviews.name
		GROUP BY game_sales.year
		HAVING COUNT(game_reviews.critic_score)>4
		ORDER BY critic_score DESC
		LIMIT 10) AS ct
INNER JOIN 
		(SELECT game_sales.year, ROUND(AVG(game_reviews.user_score),2)AS player_avg
		FROM games.game_sales
		LEFT JOIN games.game_reviews 
			ON game_sales.name=game_reviews.name
		GROUP BY game_sales.year
		HAVING COUNT(game_reviews.user_score)>4
		ORDER BY player_avg DESC
		LIMIT 10)AS ut
	ON ct.year=ut.year
GROUP BY ct.year
ORDER BY critic_score, player_score
LIMIT 10;

--Was this years good for video game makers?
--Sales in the best video games years
SELECT 
	game_sales.year, 
	SUM(game_sales.total_shipped) AS total_games_sold
FROM games.game_sales
WHERE game_sales.year in ('2008','2011','2013')
GROUP BY game_sales.year
ORDER BY total_games_sold DESC

--TOP 10 years for video makers
SELECT 
	game_sales.year, 
	SUM(game_sales.total_shipped) AS total_games_sold
FROM games.game_sales
GROUP BY game_sales.year
ORDER BY total_games_sold DESC
LIMIT 5;