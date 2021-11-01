-- DE1 Term1 Project
-- STEP 0 CREATE schema
CREATE SCHEMA imdb_small;
USE imdb_small;

-- 1. STEP: Run the imdb_small.sql script to read the datASet
-- 2. STEP: Discovery of the databASe
SHOW TABLEs;
DESCRIBE actors;
SELECT * FROM actors;
SELECT COUNT(*) FROM actors;

DROP TABLE IF EXISTS directors;

DESCRIBE actors2;
SELECT * FROM actors2; -- seems LIKE and empty TABLE but it can be calculated

DESCRIBE movies;
SELECT * FROM movies;

DESCRIBE movies_directors;
SELECT * FROM movies_directors ;

DESCRIBE movies_genres;
SELECT COUNT( distinct genre) FROM movies_genres;

DESCRIBE directors;
SELECT COUNT(*) FROM directors;

DESCRIBE directors_genres;
SELECT * FROM directors_genres;

DESCRIBE roles;
SELECT COUNT(*) FROM roles;

-- Find out hwat the prob column means
SELECT * FROM directors_genres WHERE director_id=9247;  -- drama 1, comedy 1, adventure 0.5, 
SELECT * FROM movies_directors WHERE director_id=9247; -- movie id 124110
SELECT * FROM movies_genres WHERE movie_id=124110; -- the 124110 movie is drama and comedy


-- Creating the analytical data layer
USE imdb_small;

DROP TABLE IF EXISTS actors_movies;
CREATE TABLE actors_movies AS
SELECT
	actors.id AS Actor_id,
    Concat(actors.first_name, ' ', actors.lASt_name) AS Actor,
    actors.gender AS Gender,
    roles.role AS Role,
    -- movies.id AS Movie_id,
    movies.name AS Movie,
    movies.year AS Year,
    movies.rank AS Rating,
    -- movies_directors.director_id AS Director_id,
    concat(directors.first_name,' ',directors.lASt_name) AS Director
FROM actors
LEFT JOIN roles -- we can to include every actors even if they do not have role
on roles.actor_id=actors.id
INNER JOIN movies
on movies.id=roles.movie_id
INNER JOIN movies_directors
on movies.id=movies_directors.movie_id
INNER JOIN directors
on movies_directors.director_id=directors.id
ORDER BY Actor;

SELECT * FROM actors_movies;


-- CREATE stored PROCEDURE

DROP PROCEDURE IF EXISTS CreateActorsRolesInMovies;

delimiter //

CREATE PROCEDURE CreateActorsRolesInMovies() 
BEGIN
	
    DROP TABLE IF EXISTS actors_movies;
    
    CREATE TABLE actors_movies AS
	SELECT
		actors.id AS Actor_id,
		Concat(actors.first_name, ' ', actors.lastt_name) AS Actor,
		actors.gender AS Gender,
        actors.film_COUNT AS Film_count,
		roles.role AS Role,
		-- movies.id AS Movie_id,
		movies.name AS Movie,
		movies.year AS Year,
		movies.rank AS Rating,
		-- movies_directors.director_id AS Director_id,
		concat(directors.first_name,' ',directors.lASt_name) AS Director
	FROM actors
	LEFT JOIN roles
	on roles.actor_id=actors.id
	INNER JOIN movies
	on movies.id=roles.movie_id
	INNER JOIN movies_directors
	on movies.id=movies_directors.movie_id
	INNER JOIN directors  -- 1:n becaUSE a movie can have multiple directors
	on movies_directors.director_id=directors.id
	ORDER BY 
		Actor,
        Year;



end //

delimiter ;

DROP TABLE actors_movies;
CALL CreateActorsRolesInMovies();

-- Test the stored PROCEDURE
SELECT * FROM actors_movies;

-- CREATE AN EVENT	 


SHOW VARIABLES LIKE "event_scheduler";
SET GLOBAL event_scheduler = on;

-- To Turn it OFF
-- SET GLOBAL event_scheduler = OFF;


-- Set  the tables for the event
DROP TABLE IF EXISTS actors_movies;
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	message VARCHAR(100)
    );


DELIMITER $$

CREATE EVENT CreateActorsMoviesEvent
on SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
endS CURRENT_TIMESTAMP + INTERVAL 3 MINUTE
DO
	BEGIN
		INSERT INTO messages(message) SELECT ConCAT('event:',NOW());
        DROP TABLE IF EXISTS actors_movies;
		CALL CreateActorsRolesInMovies();
	end$$
DELIMITER ;

-- Test the event
SHOW EVENTS;
SELECT * FROM messages;

-- DROP event 
TRUNCATE messages;
DROP EVENT IF EXISTS CreateActorsMoviesEvent;


-- CREATE A TIGGER
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	actor_id VARCHAR(100) NOT NULL
     );
    
TRUNCATE messages;
DROP TRIGGER IF EXISTS After_role_insert; 

DELIMITER $$

CREATE TRIGGER After_role_insert
AFTER INSERT
on roles FOR EACH ROW
BEGIN
	
	-- log the actor id of the newly inserted role
	INSERT INTO messages(actor_id) SELECT ConCAT('trigger: ', NEW.actor_id);

	-- archive the role and ASsosiated TABLE entries to actors_movies
  	INSERT INTO actors_movies
	SELECT
		actors.id AS Actor_id,
		Concat(actors.first_name, ' ', actors.lASt_name) AS Actor,
		actors.gender AS Gender,
        actors.film_COUNT AS Film_count,
		roles.role AS Role,
		movies.id AS Movie_id,
		movies.name AS Movie,
		movies.year AS Year,
		movies.rank AS Rating,
		-- movies_directors.director_id AS Director_id,
		concat(directors.first_name,' ',directors.lASt_name) AS Director
	FROM actors
	LEFT JOIN roles
	on roles.actor_id=actors.id
	INNER JOIN movies
	on movies.id=roles.movie_id
	INNER JOIN movies_directors
	on movies.id=movies_directors.movie_id
	INNER JOIN directors  -- 1:n because a movie can have multiple directors
	on movies_directors.director_id=directors.id
    WHERE actor_id=NEW.actor_id 
	ORDER BY 
		Actor,
        Year;
        
end $$

DELIMITER ;
TRUNCATE messages;
SELECT * FROM messages;
SHOW TRIGGERS;

-- TEST THE TRIGGER

INSERT INTO roles(actor_id, movie_id, role)  VALUES( 1111 , 9999 ,'Rachel Zane');
-- Cannot insert into roles table

INSERT INTO actors  VALUES(1111,'Magan','Markle','F',1);
INSERT INTO movies VALUES(9999,'Suits',2012,8.4 );
INSERT INTO directors VALUES(22,'first_name','last_name');


SELECT * FROM messages;
DROP TRIGGER IF EXISTS After_role_insert;


-- CREATING DATA MARTS AS VIEWS 

DROP PROCEDURE IF EXISTS CreateDataMarts;

DELIMITER //

CREATE PROCEDURE CreateDataMarts()
BEGIN
	-- What are the 5  highest rated movies, who is the director?
DROP VIEW IF EXISTS `Top_movies`;
CREATE VIEW `Top_movies` AS
SELECT 
	DISTINCT Movie, 
    Director, 
    Rating 
    FROM actors_movies 
    ORDER BY Rating DESC 
    LIMIT 5;

-- Which director hAS the most movies and what are there average ranks?
DROP VIEW IF EXISTS `Director_rating`;
CREATE VIEW  `Director_rating` AS
SELECT 
	Director, 
    COUNT( DISTINCT Movie) AS Number_of_movies, 
    AVG(Rating) 
    FROM actors_movies 
    GROUP BY Movie 
    ORDER BY Number_of_movies DESC; -- Actually every director hAS 1 movie in the datASet

--  Which actors appeared in the most movies and what are the average rating?
DROP VIEW IF EXISTS `Actor_avg_rating`;
CREATE VIEW `Actor_avg_rating` AS
SELECT 
	Actor, 
    COUNT(DISTINCT Movie ) AS Number_of_movies, 
    AVG(Rating) AS Average_rating 
    FROM actors_movies 
    GROUP BY Actor 
    ORDER BY Number_of_movies DESC;

-- Which movies hAS the worst ratings in 2000?
DROP VIEW IF EXISTS `Bottom_in_2000`;
CREATE VIEW `Bottom_in_2000` AS
SELECT 
	DISTINCT Movie, 
    Rating 
	FROM actors_movies 
	WHERE Year=2000 
    ORDER BY Rating ASC;

--  How many movies were CREATEd and what are their average ratings in the different years?
DROP VIEW IF EXISTS `Yearly_avg_rating`;
CREATE VIEW `Yearly_avg_rating` AS
SELECT 
	Year, 
	COUNT( DISTINCT Movie) AS Number_of_movies, 
    AVG(Rating) AS Average_raing 
	FROM actors_movies
	GROUP BY YEAR 
    ORDER BY YEAR DESC;

-- How many male and female actors are in the different movies?
DROP VIEW IF EXISTS `Gender_number`;
CREATE VIEW `Gender_number` AS
SELECT 
	Movie,
    Gender,
    COUNT( DISTINCT actor) AS Number_of_actors
	FROM actors_movies
    GROUP BY Movie, Gender
    ORDER BY Movie;
    
    
end //

DELIMITER ;

CALL CreateDataMarts();

