--- psql postgres://username@ada.mines.edu/csci403
--- Andrew Grimes. Colin Myers. Tyner Sellers.

--- DELIVERABLE 1 - DATA LOADING AND CLEANING (LN 4-123)
--- spotify table for data cleaning
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

--- load the csv's
\copy staging_spotify FROM './CS403-FP/universal_top_spotify_songs.csv' CSV HEADER;
\copy staging_happiness FROM './CS403-FP/World-happiness-report-updated_2024.csv' CSV HEADER;

--- raw values
SELECT DISTINCT country FROM staging_spotify ORDER BY country;
SELECT DISTINCT country_name FROM staging_happiness ORDER BY country_name;
SELECT DISTINCT snapshot_date FROM staging_spotify ORDER BY snapshot_date LIMIT 20;

-- standardize data countries
CREATE TEMP TABLE country_map(abbrev TEXT, fullname TEXT);
INSERT INTO country_map VALUES
    ('US','United States'),
    ('U.S.','United States'),
    ('UK','United Kingdom');

UPDATE staging_spotify s
    SET country = m.fullname
    FROM country_map m
    WHERE s.country = m.abbrev;

UPDATE staging_happiness h
    SET country_name = m.fullname
    FROM country_map m
    WHERE h.country_name = m.abbrev;

--- standardize data dates
ALTER TABLE staging_spotify ADD COLUMN snapshot_date_clean DATE;
UPDATE staging_spotify
    SET snapshot_date_clean = TO_DATE(snapshot_date,'MM/DD/YYYY');
ALTER TABLE staging_spotify 
    DROP COLUMN snapshot_date;
    RENAME COLUMN snapshot_date_clean TO snapshot_date;

--- data casting spotify table
ALTER TABLE staging_spotify
    ALTER COLUMN daily_rank TYPE INTEGER USING daily_rank::INTEGER,
    ALTER COLUMN daily_movement TYPE INTEGER USING daily_movement::INTEGER,
    ALTER COLUMN weekly_movement TYPE INTEGER USING weekly_movement::INTEGER,
    ALTER COLUMN popularity TYPE INTEGER USING popularity::INTEGER,
    ALTER COLUMN is_explicit TYPE BOOLEAN USING (is_explicit='True'),
    ALTER COLUMN duration_ms TYPE INTEGER USING duration_ms::INTEGER,
    ALTER COLUMN danceability TYPE REAL USING danceability::REAL,
    ALTER COLUMN energy TYPE REAL USING energy::REAL;
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

CREATE TABLE clean_spotify AS SELECT DISTINCT * FROM staging_spotify;
CREATE TABLE clean_happiness AS SELECT DISTINCT * FROM staging_happiness;
