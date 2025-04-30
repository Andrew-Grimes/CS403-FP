--- psql postgres://username@ada.mines.edu/csci403
--- Andrew Grimes. Colin Myers. Tyner Sellers.

--- DELIVERABLE 1 - DATA LOADING AND CLEANING (LN 4-123)
--- spotify table for data cleaning

SET ROLE group42;
SET search_path TO group42;

DROP TABLE IF EXISTS
clean_spotify,
clean_happiness,
staging_spotify,
staging_happiness;


CREATE TABLE staging_spotify (
    spotify_id TEXT,
    name TEXT,
    artists TEXT,
    daily_rank TEXT,
    daily_movement TEXT,
    weekly_movement TEXT,
    country TEXT,
    snapshot_date TEXT,
    popularity TEXT,
    is_explicit TEXT,
    duration_ms TEXT,
    album_name TEXT,
    album_release_date TEXT,
    danceability TEXT,
    energy TEXT,
    key TEXT,
    loudness TEXT,
    mode TEXT,
    speechiness TEXT,
    acousticness TEXT,
    instrumentalness TEXT,
    liveness TEXT,
    valence TEXT,
    tempo TEXT,
    time_signature TEXT
);

--- happiness table for data cleaning
CREATE TABLE staging_happiness (
    country_name TEXT,
    regional_indicator TEXT,
    ladder_score TEXT,
    upper_whisker TEXT,
    lower_whisker TEXT,
    logged_gdp_per_capita TEXT,
    social_support TEXT,
    healthy_life_expectancy TEXT,
    perception_of_corruption TEXT,
    dystopia_residual TEXT,
    positive_affect TEXT,
    negative_affect TEXT
);

--- copy the tables into staging tables for cleaning
INSERT INTO staging_spotify
SELECT * FROM spotify_songs;

INSERT INTO staging_happiness
SELECT * FROM world_happiness;


--- row count before
SELECT COUNT(*) AS spotify_rows   FROM staging_spotify;
SELECT COUNT(*) AS happiness_rows FROM staging_happiness;

--- raw values
SELECT DISTINCT country FROM staging_spotify ORDER BY country;
SELECT DISTINCT country_name FROM staging_happiness ORDER BY country_name;
SELECT DISTINCT snapshot_date FROM staging_spotify ORDER BY snapshot_date LIMIT 20;

-- standardize data countries
UPDATE staging_spotify
SET country = CASE
    WHEN country IN ('US','U.S.') THEN 'United States'
    WHEN country LIKE '% (UK' THEN 'United Kingdom'
    WHEN LOWER(country) = 'ae' THEN 'United Arab Emirates'
    WHEN LOWER(country) = 'ar' THEN 'Argentina'
    WHEN LOWER(country) = 'at' THEN 'Austria'
    WHEN LOWER(country) = 'au' THEN 'Australia'
    WHEN LOWER(country) = 'be' THEN 'Belgium'
    WHEN LOWER(country) = 'bg' THEN 'Bulgaria'
    WHEN LOWER(country) = 'bo' THEN 'Bolivia'
    WHEN LOWER(country) = 'br' THEN 'Brazil'
    WHEN LOWER(country) = 'by' THEN 'Belarus'
    WHEN LOWER(country) = 'ca' THEN 'Canada'
    WHEN LOWER(country) = 'ch' THEN 'Switzerland'
    WHEN LOWER(country) = 'cl' THEN 'Chile'
    WHEN LOWER(country) = 'co' THEN 'Colombia'
    WHEN LOWER(country) = 'cr' THEN 'Costa Rica'
    WHEN LOWER(country) = 'cz' THEN 'Czech Republic'
    WHEN LOWER(country) = 'de' THEN 'Germany'
    WHEN LOWER(country) = 'dk' THEN 'Denmark'
    WHEN LOWER(country) = 'do' THEN 'Dominican Republic'
    WHEN LOWER(country) = 'ec' THEN 'Ecuador'
    WHEN LOWER(country) = 'ee' THEN 'Estonia'
    WHEN LOWER(country) = 'eg' THEN 'Egypt'
    WHEN LOWER(country) = 'es' THEN 'Spain'
    WHEN LOWER(country) = 'fi' THEN 'Finland'
    WHEN LOWER(country) = 'fr' THEN 'France'
    WHEN LOWER(country) = 'gb' THEN 'United Kingdom'
    WHEN LOWER(country) = 'gr' THEN 'Greece'
    WHEN LOWER(country) = 'gt' THEN 'Guatemala'
    WHEN LOWER(country) = 'hk' THEN 'Hong Kong'
    WHEN LOWER(country) = 'hn' THEN 'Honduras'
    WHEN LOWER(country) = 'hu' THEN 'Hungary'
    WHEN LOWER(country) = 'id' THEN 'Indonesia'
    WHEN LOWER(country) = 'ie' THEN 'Ireland'
    WHEN LOWER(country) = 'il' THEN 'Israel'
    WHEN LOWER(country) = 'in' THEN 'India'
    WHEN LOWER(country) = 'is' THEN 'Iceland'
    WHEN LOWER(country) = 'it' THEN 'Italy'
    WHEN LOWER(country) = 'jp' THEN 'Japan'
    WHEN LOWER(country) = 'kr' THEN 'South Korea'
    WHEN LOWER(country) = 'kz' THEN 'Kazakhstan'
    WHEN LOWER(country) = 'lt' THEN 'Lithuania'
    WHEN LOWER(country) = 'lu' THEN 'Luxembourg'
    WHEN LOWER(country) = 'lv' THEN 'Latvia'
    WHEN LOWER(country) = 'ma' THEN 'Morocco'
    WHEN LOWER(country) = 'mx' THEN 'Mexico'
    WHEN LOWER(country) = 'my' THEN 'Malaysia'
    WHEN LOWER(country) = 'ng' THEN 'Nigeria'
    WHEN LOWER(country) = 'ni' THEN 'Nicaragua'
    WHEN LOWER(country) = 'nl' THEN 'Netherlands'
    WHEN LOWER(country) = 'no' THEN 'Norway'
    WHEN LOWER(country) = 'nz' THEN 'New Zealeand'
    WHEN LOWER(country) = 'pa' THEN 'Panama'
    WHEN LOWER(country) = 'pe' THEN 'Peru'
    WHEN LOWER(country) = 'ph' THEN 'Philippines'
    WHEN LOWER(country) = 'pk' THEN 'Pakistan'
    WHEN LOWER(country) = 'pl' THEN 'Poland'
    WHEN LOWER(country) = 'pt' THEN 'Portugal'
    WHEN LOWER(country) = 'py' THEN 'Paraguay'
    WHEN LOWER(country) = 'ro' THEN 'Romania'
    WHEN LOWER(country) = 'sa' THEN 'Saudi Arabia'
    WHEN LOWER(country) = 'se' THEN 'Sweden'
    WHEN LOWER(country) = 'sg' THEN 'Singapore'
    WHEN LOWER(country) = 'sk' THEN 'Slovakia'
    WHEN LOWER(country) = 'sv' THEN 'El Salvador'
    WHEN LOWER(country) = 'th' THEN 'Thailand'
    WHEN LOWER(country) = 'tr' THEN 'Turkey'
    WHEN LOWER(country) = 'tw' THEN 'Taiwan'
    WHEN LOWER(country) = 'ua' THEN 'Ukraine'
    WHEN LOWER(country) = 'uy' THEN 'Uruguay'
    WHEN LOWER(country) = 've' THEN 'Venezuela'
    WHEN LOWER(country) = 'vn' THEN 'Vietnam'
    WHEN LOWER(country) = 'za' THEN 'South Africa'
    ELSE country
END;

-- Normalize country names in staging_happiness
UPDATE staging_happiness
SET country_name = CASE
    WHEN country_name IN ('US','U.S.') THEN 'United States'
    WHEN country_name LIKE '% (UK)' THEN 'United Kingdom'
    ELSE INITCAP(country_name)
END;

--- standardize data dates
ALTER TABLE staging_spotify ADD COLUMN snapshot_date_clean DATE;
UPDATE staging_spotify
SET snapshot_date_clean = TO_DATE(snapshot_date,'YYYY-MM-DD');
-- First, drop the old column
ALTER TABLE staging_spotify
    DROP COLUMN snapshot_date;

-- Then, rename the clean column to the original column name
ALTER TABLE staging_spotify
    RENAME COLUMN snapshot_date_clean TO snapshot_date;
--- data casting spotify table
ALTER TABLE staging_spotify
    ALTER COLUMN daily_rank TYPE INTEGER USING daily_rank::INTEGER,
    ALTER COLUMN daily_movement TYPE INTEGER USING daily_movement::INTEGER,
    ALTER COLUMN weekly_movement TYPE INTEGER USING weekly_movement::INTEGER,
    ALTER COLUMN popularity TYPE INTEGER USING popularity::INTEGER,
    ALTER COLUMN is_explicit TYPE BOOLEAN USING (is_explicit='True'),
    ALTER COLUMN duration_ms TYPE INTEGER USING duration_ms::INTEGER,
    ALTER COLUMN album_release_date TYPE DATE USING TO_DATE(album_release_date,'YYYY-MM-DD'),
    ALTER COLUMN danceability TYPE REAL USING danceability::REAL,
    ALTER COLUMN energy TYPE REAL USING energy::REAL,
    ALTER COLUMN key TYPE INTEGER USING key::INTEGER,
    ALTER COLUMN loudness TYPE REAL USING loudness::REAL,
    ALTER COLUMN mode TYPE INTEGER USING mode::INTEGER,
    ALTER COLUMN speechiness TYPE REAL USING speechiness::REAL,
    ALTER COLUMN acousticness TYPE REAL USING acousticness::REAL,
    ALTER COLUMN instrumentalness TYPE REAL USING instrumentalness::REAL,
    ALTER COLUMN liveness TYPE REAL USING liveness::REAL,
    ALTER COLUMN valence TYPE REAL USING valence::REAL,
    ALTER COLUMN tempo TYPE REAL USING tempo::REAL,
    ALTER COLUMN time_signature TYPE INTEGER USING time_signature::INTEGER;

--- data casting happiness table
ALTER TABLE staging_happiness
    ALTER COLUMN ladder_score TYPE NUMERIC USING ladder_score::NUMERIC,
    ALTER COLUMN upper_whisker TYPE NUMERIC USING upper_whisker::NUMERIC,
    ALTER COLUMN lower_whisker TYPE NUMERIC USING lower_whisker::NUMERIC,
    ALTER COLUMN logged_gdp_per_capita TYPE NUMERIC USING logged_gdp_per_capita::NUMERIC,
    ALTER COLUMN social_support TYPE NUMERIC USING social_support::NUMERIC,
    ALTER COLUMN healthy_life_expectancy TYPE NUMERIC USING healthy_life_expectancy::NUMERIC,
    ALTER COLUMN perception_of_corruption TYPE NUMERIC USING perception_of_corruption::NUMERIC,
    ALTER COLUMN dystopia_residual TYPE NUMERIC USING dystopia_residual::NUMERIC,
    ALTER COLUMN positive_affect TYPE NUMERIC USING positive_affect::NUMERIC,
    ALTER COLUMN negative_affect TYPE NUMERIC USING negative_affect::NUMERIC;

--- validate, remove extra
SELECT * FROM staging_spotify WHERE country IS NULL OR snapshot_date IS NULL;
SELECT * FROM staging_happiness WHERE country_name  IS NULL OR ladder_score IS NULL;

CREATE TABLE clean_spotify AS SELECT DISTINCT * FROM staging_spotify WHERE EXTRACT(YEAR FROM snapshot_date) = 2024;
CREATE TABLE clean_happiness AS SELECT DISTINCT * FROM staging_happiness;

--- row count after
SELECT COUNT(*) AS clean_spotify_rows   FROM clean_spotify;
SELECT COUNT(*) AS clean_happiness_rows FROM clean_happiness;
