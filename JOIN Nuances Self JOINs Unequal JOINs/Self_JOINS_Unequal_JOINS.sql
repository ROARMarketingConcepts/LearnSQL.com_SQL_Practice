-- Display two columns: speaker1 and speaker2. Both columns should 
-- contain the speakers' names, and together they should form pairs of 
-- speakers such that one is a native speaker of a language and the other 
-- is studying it. For example, Ann is a native English speaker learning French, 
-- and Hugo is a native Spanish speaker learning English; they make a pair for 
-- studying English. The ID of speaker1 should be smaller than the ID of speaker2.

-- Use a common table expression to join the tables speaker and language_speaker first. 
-- Then, use a self-join to select the pairs and a non-equi join to compare the IDs so that 
-- you avoid listing the same pair twice with the elements swapped.

WITH speaker_language_table AS 

(SELECT *
FROM speaker s
LEFT JOIN language_speaker ls
ON s.id=ls.speaker_id)

SELECT DISTINCT speaker1.name AS speaker1, speaker2.name AS speaker2 
FROM speaker_language_table speaker1
INNER JOIN speaker_language_table speaker2
ON speaker1.language_id=speaker2.language_id
AND speaker1.native != speaker2.native
AND speaker1.id < speaker2.id     -- included to avoid listing the same pair twice with the elements swapped.