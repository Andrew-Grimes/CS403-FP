import pg8000
import pandas
import Connection 

df = pandas.read_csv("universal_top_spotify_songs.csv")
connection = Connection.Connection().get_connection()
cursor = connection.cursor()

cursor.execute("""
    CREATE TABLE IF NOT EXISTS spotify_songs (
        spotify_id TEXT,
        name TEXT,
        artists TEXT,
        daily_rank INTEGER,
        daily_movement INTEGER,
        weekly_movement INTEGER,
        country TEXT,
        snapshot_date DATE,
        popularity INTEGER,
        is_explicit BOOLEAN,
        duration_ms INTEGER,
        album_name TEXT,
        album_release_date DATE,
        danceability REAL,
        energy REAL,
        key INTEGER,
        loudness REAL,
        mode INTEGER,
        speechiness REAL,
        acousticness REAL,
        instrumentalness REAL,
        liveness REAL,
        valence REAL,
        tempo REAL,
        time_signature INTEGER
    )
""")

print("table made")
df = df.where(pandas.notnull(df), None)
values = [tuple(row) for row in df.itertuples(index=False, name=None)]

insert_query = """
    INSERT INTO spotify_songs (
        spotify_id, name, artists, daily_rank, daily_movement, weekly_movement,
        country, snapshot_date, popularity, is_explicit, duration_ms, album_name,
        album_release_date, danceability, energy, key, loudness, mode, speechiness,
        acousticness, instrumentalness, liveness, valence, tempo, time_signature
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

print("LOADING")
cursor.executemany(insert_query, values)
print("DONE")

connection.commit()
cursor.close()
connection.close()

