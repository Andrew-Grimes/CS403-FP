--- psql postgres://username@ada.mines.edu/csci403
--- Andrew Grimes. Colin Myers. Tyner Sellers.

--- DELIVERABLE 2 - INTERESTING QUERIES 
--- spotify table for data cleaning
SET search_path TO group42;

--- Find the average danceability of the top 10 most popular songs per country and compares it to the happiness score of that country
WITH top_songs_per_country AS (
    SELECT
        s.country,
        s.danceability,
        s.popularity,
        ROW_NUMBER() OVER (PARTITION BY s.country ORDER BY s.popularity DESC) AS rank
    FROM clean_spotify s
),
avg_danceability_per_country AS (
    SELECT
        country,
        AVG(danceability) AS avg_danceability
    FROM top_songs_per_country
    WHERE rank <= 10
    GROUP BY country
)
SELECT * FROM top_songs_per_country;
SELECT
    adc.country,
    adc.avg_danceability,
    h.ladder_score
FROM avg_danceability_per_country adc
JOIN clean_happiness h ON adc.country = h.country_name
ORDER BY adc.avg_danceability DESC;


-- Compare the happiness score of countries with above and below average instrumentalness
WITH global_avg_instrumentalness AS (
    SELECT AVG(instrumentalness) AS avg_instrumentalness
    FROM clean_spotify
),
top_5_songs_per_country AS (
    SELECT
        s.country,
        AVG(s.instrumentalness) AS avg_instrumentalness

    FROM clean_spotify s
    GROUP BY s.country
    HAVING COUNT(s.spotify_id) >= 5
),
classified_countries AS (
    SELECT
        t.country,
        CASE
            WHEN t.avg_instrumentalness
     < (SELECT avg_instrumentalness
     FROM global_avg_instrumentalness) THEN 'Below Average'
            ELSE 'Above Average'
        END AS instrumentalness_group
    FROM top_5_songs_per_country t
)
SELECT
    instrumentalness_group,
    AVG(h.ladder_score) AS avg_happiness_score
FROM classified_countries c
JOIN clean_happiness h ON c.country = h.country_name
GROUP BY instrumentalness_group
ORDER BY avg_happiness_score DESC;


-- Compare the popularity score of songs with above and below average danceability
WITH global_avg_danceability AS (
    SELECT AVG(danceability) AS global_avg_danceability
    FROM clean_spotify
),
grouped_by_danceability AS (
    SELECT
        s.popularity,
        s.danceability,
        CASE
            WHEN s.danceability > (SELECT global_avg_danceability FROM global_avg_danceability) THEN 'High Danceability'
            ELSE 'Low Danceability'
        END AS danceability_group
    FROM clean_spotify s
)
SELECT
    danceability_group,
    AVG(popularity) AS avg_popularity
FROM grouped_by_danceability
GROUP BY danceability_group
ORDER BY avg_popularity DESC;





-- Compare the happiness score of countries with above and below average perception of corruption
WITH corruption_categories AS (
    SELECT 
        country_name,
        perception_of_corruption,
        CASE
            WHEN perception_of_corruption <= (SELECT AVG(perception_of_corruption) FROM clean_happiness) - 0.2 THEN 'Low'
            WHEN perception_of_corruption >= (SELECT AVG(perception_of_corruption) FROM clean_happiness) + 0.2 THEN 'High'
            ELSE 'Medium'
        END AS corruption_category
    FROM clean_happiness
)

SELECT 
    h.country_name,
    h.ladder_score,
    c.corruption_category
FROM clean_happiness h
JOIN corruption_categories c ON h.country_name = c.country_name
ORDER BY c.corruption_category, h.ladder_score DESC;
