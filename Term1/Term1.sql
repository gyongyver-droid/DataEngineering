-- DE1 Term1 Project
-- STEP 0 CREATE schema
CREATE schema imdb_small;
use imdb_small;

-- 1. STEP: Run the imdb_small.sql script to read the dataset
-- 2. STEP: Discovery of the database
show tables;
describe actors;
SELECT * FROM actors;
SELECT count(*) FROM actors;

describe actors2;
SELECT * FROM actors2; -- seems like and empty table but it can be calculated

describe movies;
SELECT * FROM movies;

describe movies_directors;
SELECT * FROM movies_directors ;

describe movies_genres;
SELECT count( distinct genre) FROM movies_genres;

describe directors;
SELECT count(*) FROM directors;

describe directors_genres;
SELECT * FROM directors_genres;

describe roles;
SELECT count(*) FROM roles;

-- Find out hwat the prob column means
SELECT * FROM directors_genres where director_id=9247;  -- drama 1, comedy 1, adventure 0.5, 
SELECT * FROM movies_directors where director_id=9247; -- movie id 124110
SELECT * FROM movies_genres where movie_id=124110; -- the 124110 movie is drama and comedy

-- Do some cleaning
-- actors name might concain '' 

-- Creating the analytical data layer
use imdb_small;

drop table if exists actors_movies;
create table actors_movies as
SELECT
	actors.id as Actor_id,
    Concat(actors.first_name, ' ', actors.last_name) as Actor,
    actors.gender as Gender,
    roles.role as Role,
    -- movies.id as Movie_id,
    movies.name as Movie,
    movies.year as Year,
    movies.rank as Rating,
    -- movies_directors.director_id as Director_id,
    concat(directors.first_name,' ',directors.last_name) as Director
FROM actors
left join roles -- we can to include every actors even if they do not have role
on roles.actor_id=actors.id
inner join movies
on movies.id=roles.movie_id
inner join movies_directors
on movies.id=movies_directors.movie_id
inner join directors
on movies_directors.director_id=directors.id
order by Actor;

select * from actors_movies;


-- CREATE stored procedure


drop procedure if exists CreateActorsRolesInMovies;

delimiter //

CREATE procedure CreateActorsRolesInMovies() 
begin
	
    drop table if exists actors_movies;
    
    CREATE table actors_movies as
	SELECT
		actors.id as Actor_id,
		Concat(actors.first_name, ' ', actors.last_name) as Actor,
		actors.gender as Gender,
        actors.film_count as Film_count,
		roles.role as Role,
		-- movies.id as Movie_id,
		movies.name as Movie,
		movies.year as Year,
		movies.rank as Rating,
		-- movies_directors.director_id as Director_id,
		concat(directors.first_name,' ',directors.last_name) as Director
	FROM actors
	left join roles
	on roles.actor_id=actors.id
	inner join movies
	on movies.id=roles.movie_id
	inner join movies_directors
	on movies.id=movies_directors.movie_id
	inner join directors  -- 1:n because a movie can have multiple directors
	on movies_directors.director_id=directors.id
	order by 
		Actor,
        Year;



end //

delimiter ;

DROP TABLE actors_movies;
CALL CreateActorsRolesInMovies();

-- Test the stored procedure
SELECT * FROM actors_movies;

-- CREATE A TIGGER
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	actor_id INT  NOT NULL,
    movie_id INT NOT NULL,
    role VARCHAR(100) 
    );

DROP TRIGGER IF EXISTS After_role_insert; 

DELIMITER $$

CREATE TRIGGER After_role_insert
AFTER INSERT
ON roles FOR EACH ROW
BEGIN
	
	-- log the actor id of the newly inserted role
	INSERT INTO messages VALUES(NEW.actor_id, NEW.movie_id, NEW.role );

	-- archive the role and assosiated table entries to actors_movies
  	INSERT INTO actors_movies
	SELECT
		actors.id as Actor_id,
		Concat(actors.first_name, ' ', actors.last_name) as Actor,
		actors.gender as Gender,
        actors.film_count as Film_count,
		roles.role as Role,
		movies.id as Movie_id,
		movies.name as Movie,
		movies.year as Year,
		movies.rank as Rating,
		-- movies_directors.director_id as Director_id,
		concat(directors.first_name,' ',directors.last_name) as Director
	FROM actors
	left join roles
	on roles.actor_id=actors.id
	inner join movies
	on movies.id=roles.movie_id
	inner join movies_directors
	on movies.id=movies_directors.movie_id
	inner join directors  -- 1:n because a movie can have multiple directors
	on movies_directors.director_id=directors.id
    where actor_id=NEW.actor_id 
	order by 
		Actor,
        Year;
        
END $$

DELIMITER ;
truncate messages;
select * from messages;
SHOW TRIGGERS;

-- TEST THE TRIGGER
select * from roles;
select * from actors;
select * from movies;
INSERT INTO roles(actor_id, movie_id, role) VALUES ( 11111 , 44444 ,'Rachel Zane');
INSERT INTO actors  VALUES(11111,'Magan','Markle','F',1);
INSERT INTO movies VALUES(44444,'Suits',2012,8.4 );
INSERT INTO imdb_small.roles VALUES(11111, 44444, '');

select * from messages;
-- CREATING DATA MARTS AS VIEWS 


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

-- Which director has the most movies and what are there average ranks?
DROP VIEW IF EXISTS `Director_rating`;
CREATE VIEW  `Director_rating` AS
SELECT 
	Director, 
    COUNT( DISTINCT Movie) AS Number_of_movies, 
    AVG(Rating) 
    FROM actors_movies 
    GROUP BY Movie 
    ORDER BY Number_of_movies DESC; -- Actually every director has 1 movie in the dataset

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

-- Which  10 movies has the worst ratings in 2000?
DROP VIEW IF EXISTS `Bottom_in_2000`;
CREATE VIEW `Bottom_in_2000` AS
SELECT 
	DISTINCT Movie, 
    Rating 
	FROM actors_movies 
	WHERE Year=2000 
    ORDER BY Rating ASC;

--  How many movies were created and what are their average ratings in the different years?
DROP VIEW IF EXISTS `Yearly_avg_rating`;
CREATE VIEW `Yearly_avg_rating` AS
SELECT 
	Year, 
	COUNT( DISTINCT Movie) AS Number_of_movies, 
    AVG(Rating) AS Average_raing 
	FROM actors_movies
	GROUP BY YEAR 
    ORDER BY YEAR DESC;




