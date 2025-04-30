--- psql postgres://username@ada.mines.edu/csci403
--- Andrew Grimes. Colin Myers. Tyner Sellers.

--- DELIVERABLE 2 - INTERESTING QUERIES 
--- spotify table for data cleaning
SET search_path TO group42;

--- Find the average danceability of the top 10 most popular songs per country and compares it to the happiness score of that country
WITH top_10_songs_per_country AS (
    -- Select the top 10 most popular songs per country
    SELECT
        s.country,
        s.danceability,
        s.popularity,
        ROW_NUMBER() OVER (PARTITION BY s.country ORDER BY s.popularity DESC) AS rank
    FROM clean_spotify s
),
avg_danceability_per_country AS (
    -- Calculate the average danceability for the top 10 songs per country
    SELECT
        country,
        AVG(danceability) AS avg_danceability
    FROM top_10_songs_per_country
    WHERE rank <= 10  -- Select only the top 10 songs per country
    GROUP BY country
)
-- Join with the happiness scores to compare with ladder score
SELECT
    adc.country,
    adc.avg_danceability,
    h.ladder_score
FROM avg_danceability_per_country adc
JOIN clean_happiness h ON adc.country = h.country_name
ORDER BY adc.avg_danceability DESC;

-- Compare the happiness score of countries with above and below average liveness
WITH global_avg_speechiness AS (
    -- Calculate the global average liveness for all songs
    SELECT AVG(liveness) AS avg_speechiness
    FROM clean_spotify
),
top_5_songs_per_country AS (
    -- Select the top 5 most popular songs for each country and calculate average liveness
    SELECT
        s.country,
        AVG(s.liveness) AS avg_speechiness
    FROM clean_spotify s
    GROUP BY s.country
    HAVING COUNT(s.spotify_id) >= 5  -- Only include countries with at least 5 songs
),
classified_countries AS (
    -- Classify countries into below and above average liveness
    SELECT
        t.country,
        CASE
            WHEN t.avg_speechiness < (SELECT avg_speechiness FROM global_avg_speechiness) THEN 'Below Average'
            ELSE 'Above Average'
        END AS speechiness_group
    FROM top_5_songs_per_country t
)
-- Compare the average happiness score of the two groups
SELECT
    speechiness_group,
    AVG(h.ladder_score) AS avg_happiness_score
FROM classified_countries c
JOIN clean_happiness h ON c.country = h.country_name
GROUP BY speechiness_group
ORDER BY avg_happiness_score DESC;
