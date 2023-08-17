##1. File Upload
To perform the file upload, a database in Snowflake was used.
Subsequently, I created a Python code that read each sheet and loaded each data into the database.

(See files: requirements_colab.txt, La Liga - python.py)

##2. Store Procedure and queries
In order to create the general table, I used functions like REGEX to generate new fields like name_team1, name_team2, etc., to ensure cleaner data.
Afterwards, I performed summations by season and team, and finally stored it in the stored procedure which takes the season as an input variable.
On the other hand, for the dashboard, I prepared a query that allows me to have a consolidated view by team, season, and game number.

(See file: La Liga - Queries.sql)

##3. Dashboard
First, I loaded 2 files into Power BI: investments.csv and LA LIGA.csv.
Next, I added measures to have the desired matrix (General Table). To color values based on their category, I used the RANKX function to create a dynamic ranking.
Afterwards, for analysis, I created a summarized table (RESuMEN) with team, season, and total score to have the ranking. I added new fields like "Affordable?" and "Not loses category?" to perform the desired analysis.
Finally, based on the charts, I created a presentation showcasing the results and insights obtained.

(See file: La Liga - Presentation.pptx)