# DE1 Term1 Project Documentation

### Project interpretation
In the project I plan to analyze an IMDB relational dataset containing movies, genres, directors, actors and roles. 


### Analytics plan

 - 1. Load, understand nad descibe the data, do some data cleaning if needed
 - 2. Plan the analytical layer
 - 3. Write ETL pipeline (as stored procedure) to create the analytical data layer
 - 4. Create event / trigger and test
 - 5. Write ETL pipeline to create data marts
 
 Illustration:
 
 
 

### Data Source and overview

IMDB dataset
https://relational.fit.cvut.cz/dataset/IMDb


![image](https://user-images.githubusercontent.com/57848147/139240147-91ca1605-c798-4933-9bb0-ab9896ecd1cd.png)


The database contains 7 tables:
- actors ( + film count)
- roles
- movies
- movies_genres
- movies_directors
- directors
- directors_genres

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

#### Dimensions
#### Transformations
#### Illustration


![image](https://user-images.githubusercontent.com/57848147/139247143-2f287a2b-812f-4803-857e-6ac7430608d5.png)



## Data marts 
