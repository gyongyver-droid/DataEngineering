drop schema  if exists birdstrikes;
create schema birdstrikes;
use birdstrikes;

CREATE TABLE birdstrikes 
(id INTEGER NOT NULL,
aircraft VARCHAR(32),
flight_date DATE NOT NULL,
damage VARCHAR(16) NOT NULL,
airline VARCHAR(255) NOT NULL,
state VARCHAR(255),
phase_of_flight VARCHAR(32),
reported_date DATE,
bird_size VARCHAR(16),
cost INTEGER NOT NULL,
speed INTEGER,PRIMARY KEY(id));

show variables like "secure_file_priv";
show variables like "local_infile";

LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/birdstrikes_small.csv' 
INTO TABLE birdstrikes 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
reported_date = nullif(@v_reported_date, ''),
speed = nullif(@v_speed, '');

-- exercise  1
create table employee
(id integer not null,
employee_name varchar(250) not null, primary key(id));

-- exercise 2
select state from birdstrikes limit 144,1;  -- Tennessee

-- exercise 3
select flight_date from birdstrikes order by flight_date DESC limit 1; -- 2000-04-18

-- exercise 4
select distinct cost from birdstrikes order by cost desc limit 49,1; -- 5345

-- exercise 5
 select state from birdstrikes where state!='' and bird_size!='' limit 1,1; -- Colorado
 
 -- exercise 6 
select @dateofflight:= flight_date from birdstrikes where state='colorado' and weekofyear(flight_date)=52;
select @now:=now();
select DATEDIFF(@now, @dateofflight) as Difference; -- 7938
