-- load data 
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

-- exercise 1 
-- exercise 1
SELECT aircraft, airline, speed,
	if(speed<100 or speed is null,'LOW SPEED','HIGH SPEED')
	FROM  birdstrikes ORDER BY speed;

-- exercise 2 
select count(distinct aircraft) from birdstrikes;
-- 3

-- exercise 3 
select min(speed) from birdstrikes where aircraft like 'h%'; 
-- 9

-- exercise 4 
select phase_of_flight, count(*) as count from birdstrikes group by phase_of_flight order by count limit 1; 
-- Taxi 


-- exercise 5
select phase_of_flight, round(avg(cost)) as average from birdstrikes group by phase_of_flight order by average desc limit 1;
-- climb

-- exercise 6 
select state, avg(speed) as average_speed from birdstrikes group by state having length(state) <5 order by average_speed desc limit 1;
-- Iowa

