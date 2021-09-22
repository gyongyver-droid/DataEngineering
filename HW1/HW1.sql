drop schema if exists socialmedia;
create schema socialmedia;
use socialmedia;
SHOW VARIABLES LIKE "secure_file_priv";
SHOW VARIABLES LIKE "local_infile";

Create table friends
( Friend_1 integer not null,
Friend_2 integer not null);
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/friends_table.csv' 
INTO TABLE friends
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
Ignore 1 lines (Friend_1, Friend_2);
describe friends;

-- reading reactions table
Create table reactions 
( User_ integer not null, 
Reaction_type VARCHAR(32),
Reaction_date integer not null);
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/reactions_table.csv' 
INTO TABLE reactions
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
Ignore 1 lines
(User_, Reaction_type, Reaction_date);

select Reaction_type from reactions
where user_ between 1 and 100;

Create table posts 
( User_ integer not null, 
Post_type VARCHAR(32),
Post_date integer not null);
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/posts_table.csv' 
INTO TABLE posts
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
Ignore 1 lines
(User_, Post_type, Post_date);

select Post_type from posts
where user_ between 1 and 10;

Create table users 
( Surname VARCHAR(32), 
Name VARCHAR(32),
Age integer not null,
Subscription_date integer not null);
LOAD DATA INFILE 'c:/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_table.csv' 
INTO TABLE users
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
Ignore 1 lines
(Surname, Name,Age, Subscription_date);

describe users;