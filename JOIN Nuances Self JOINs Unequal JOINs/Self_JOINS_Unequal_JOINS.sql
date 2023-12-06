WITH speakers_languages_table AS

(SELECT *
FROM speaker s
LEFT JOIN language_speaker ls
ON s.id=ls.speaker_id)

studying_speakers AS 

(SELECT s.id,s.name AS speaker2,l.id AS studying_language_id,l.name
FROM speaker s
LEFT JOIN language_speaker ls
ON s.id=ls.speaker_id
LEFT JOIN language l
ON ls.language_id=l.id
WHERE native='f')

SELECT speaker1, speaker2
FROM native_speakers ns
INNER JOIN studying_speakers ss
ON ns.native_language_id=ss.studying_language_id
