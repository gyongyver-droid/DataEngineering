# DE1 Term1 Project Documentation

### Project interpretation
In the project I plan to analyze an IMDB relational dataset containing movies, genres, directors, actors and roles. The data source was available as an SQL file which serve as my operational data layer. Then I created an ETL pipeline to build my an anylytical layer. 


### Analytics plan

 - 1. Load, understand and descibe the data
 - 2. Plan the analytical layer
 - 3. Write ETL pipeline (as stored procedure) to create the analytical data layer
 - 4. Create event / trigger and test
 - 5. Ask question that interests as an analyst
 - 6. Write ETL pipeline to create data marts
 
 Illustration:
 
 ![Analytics plan](https://user-images.githubusercontent.com/57848147/139607533-d0c4edb3-901c-4766-8242-118a2f08d264.png)

 

### Data Source and overview

IMDB dataset
https://relational.fit.cvut.cz/dataset/IMDb


![bitmap](https://user-images.githubusercontent.com/57848147/139670978-254f49ab-9ed7-413e-b896-24b48ca422f3.png)

The database contains 7 tables:
- actors

 The actors table contains the actors' id, their first name and last name, their gender and fiml count they played in. There are 1907 actors in the tabe.
 
- roles

 The roles table consists of the the role  itself, the actor  id and the movie id in which the role was played. There are 1989 roles in the table
 
- movies

  The movies table had the movies' id, name, the year it was published and the IMDB rank. The IMDB rank is and integer that ranges from 0 to 10. There are 36 movies in the table.
  
- movies_genres

 The movies_genres table show the movie's genre for ecery movie id. It important to note that a movie can have multiple genres. There are 16 different genres in the table.
 
- movies_directors

  The movies_directors table contains the movie ids and directors ids. Similarly to genres, a movie may have multiple directos. 
  
- directors

  The directors table is composed of the director id, first name and last name. There are 34 directors in the table.
  
- directors_genres

 The directors_genres table has director id, the genres connected to him/her and probability. 
 
 Originally, the file ocntained a table called **actors2** which did no contain anything, so I dropped that table.

### Operational data layer

This is my operational data layer. As an operational layer it is process oriented. 

### Analytical questions 
- What are the 5  highest rated movies, who is the director?
 
- How many male and female actors are in the 3 highest rated movies?
 
- Which director has the most movies and what are there average ratings?

- Which 5 movies has the worst rating in 2000?

- Which actors appeared in the most movies and what are the average rating?

- How many movies were created and what are their average ratings in the different years?

### Analytical layer

The stores the data as a warehouse and 

#### Dimensions

My analytical layer has 4 dimensions: 
 1) actors: id, first and last name connected, gender, film count
 2) roles: role
 3) movies: movie name, year, rating
 4) directors: first and last name connected

All dimensions have more attributes whixh are included in the analytical layer. The one mive attribute I left out was the genre variable, because I found it unnecessary for my analysis. If an analysit is interested in genres it can be inlcuded in the layer or an other analytical layer can be built. 


#### Transformations

I performed 2 trnasformation in the ETL pipeline, both are connected to names. Firstly I conjoined the first and last name of the actors, secondly I did the same with the directors name. All of the orher variables are best described as they are so I did not see any other useful transformation.

#### Illustration
PLease see my analytical layer here:

![Table](https://user-images.githubusercontent.com/57848147/139598391-0d7b53d1-e7e1-4673-b35c-35c9c72545d3.png)


## Data marts 
