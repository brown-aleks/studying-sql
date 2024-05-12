/* MySQL */

/* Add `orderNo` column */

ALTER TABLE AlbumsSongs ADD orderNo INT NOT NULL DEFAULT 0;
SHOW CREATE TABLE AlbumsSongs;

WITH ranked_songs AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY ALBUMID ASC, SONGID ASC) AS row_num,
        ALBUMID,
        SONGID,
        ORDERNO
    FROM PUBLIC.ALBUMSSONGS
)
UPDATE PUBLIC.ALBUMSSONGS AS a
SET ORDERNO = r.row_num
FROM ranked_songs AS r
WHERE a.ALBUMID = r.ALBUMID AND a.SONGID = r.SONGID;

ALTER TABLE AlbumsSongs ALTER orderNo DROP DEFAULT;
SHOW CREATE TABLE AlbumsSongs;

/* Cumulative sum */

SELECT Albums.name, AlbumsSongs.*
FROM Albums
JOIN AlbumsSongs ON Albums.albumId = AlbumsSongs.albumId
WHERE Albums.albumId = 1;

SELECT Albums.name, AlbumsSongs.*, AlbumsSongs2.*
FROM Albums
JOIN AlbumsSongs ON Albums.albumId = AlbumsSongs.albumId
JOIN AlbumsSongs AlbumsSongs2 ON AlbumsSongs.albumId = AlbumsSongs2.albumId
                             AND AlbumsSongs.orderNo >= AlbumsSongs2.orderNo
WHERE Albums.albumId = 1;

SELECT Albums.name, Songs.name, Songs2.duration, AlbumsSongs.*, AlbumsSongs2.*
FROM Albums
JOIN AlbumsSongs ON Albums.albumId = AlbumsSongs.albumId
JOIN AlbumsSongs AlbumsSongs2 ON AlbumsSongs.albumId = AlbumsSongs2.albumId
                             AND AlbumsSongs.orderNo >= AlbumsSongs2.orderNo
JOIN Songs ON AlbumsSongs.songId = Songs.songId
JOIN Songs Songs2 ON AlbumsSongs2.songId = Songs2.songId
WHERE Albums.albumId = 1;

SELECT Albums.name, AlbumsSongs.orderNo, Songs.name, SEC_TO_TIME(SUM(TIME_TO_SEC(Songs2.duration)))
FROM Albums
JOIN AlbumsSongs ON Albums.albumId = AlbumsSongs.albumId
JOIN AlbumsSongs AlbumsSongs2 ON AlbumsSongs.albumId = AlbumsSongs2.albumId
                             AND AlbumsSongs.orderNo >= AlbumsSongs2.orderNo
JOIN Songs ON AlbumsSongs.songId = Songs.songId
JOIN Songs Songs2 ON AlbumsSongs2.songId = Songs2.songId
WHERE Albums.albumId = 1
GROUP BY Songs.songId
ORDER BY AlbumsSongs.orderNo;
