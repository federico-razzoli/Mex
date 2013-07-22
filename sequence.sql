/*
	Sequence Storage Engine Examples
	Copyright Federico Razzoli  2013
	
	This file is part of MEX (MariaDB EXamples & EXperiments).
	
	MEX is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published by
	the Free Software Foundation, version 3 of the License.
	
	MEX is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.
	
	You should have received a copy of the GNU Affero General Public License
	along with MEX.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
	This file contains Examples & Experiments on the Sequence Storage Engine,
	introduced in MariaDB 10.0.3.
	All the statements can easily be adapted to particular use cases.
*/



/*
 *	SEQUENCE.001 - Find holes
 *	=========================
 */


-- Find holes in a column;
-- useful if the column is used for sorting rows.


CREATE TABLE t1 (c TINYINT UNSIGNED) ENGINE=InnoDB;
INSERT INTO t1 VALUES (1), (2), (3), (5), (10);
SELECT s.seq FROM seq_1_to_10 s LEFT JOIN t1 t ON s.seq = t.c WHERE t.c IS NULL;


/*
 *	SEQUENCE.002 - Sequence cache
 *	=============================
 */


-- Put the sequence into a cache (temporary table).


DROP PROCEDURE IF EXISTS create_temporary_sequence_cache;
CREATE PROCEDURE create_temporary_sequence_cache(IN seq_name VARCHAR(64))
	MODIFIES SQL DATA
	COMMENT 'Create temptable overriding seq'
BEGIN
	-- create & populate cache table
	SET @__sql = CONCAT('CREATE TEMPORARY TABLE ', seq_name, ' (seq INT UNSIGNED NOT NULL) SELECT seq FROM ', seq_name, ';');
	PREPARE __sql FROM @__sql;
	EXECUTE __sql;
	
	-- if SE is not MEMORY, change it
	IF default_tmp_storage_engine NOT LIKE 'MEMORY' THEN
		SET @__sql = CONCAT('ALTER TABLE ', seq_name, ' ENGINE = MEMORY;');
		PREPARE __sql FROM @__sql;
		EXECUTE __sql;
	END IF;
	
	-- free resources
	DEALLOCATE PREPARE __sql;
	SET @__sql = NULL;
END;


/*
 *	SEQUENCE.003 - Numbers combination
 *	==================================
 */


-- Build a combination of numbers


SELECT s1.seq, s2.seq FROM seq_1_to_3 s1 JOIN seq_1_to_3 s2 ORDER BY 1, 2;


/*
 *	SEQUENCE.004 - FLOAT sequence
 *	=============================
 */


-- Sequence of FLOAT values


SELECT TRUNCATE(seq / 100, 2) AS seq FROM seq_0_to_100;



/*
 *	SEQUENCE.005 - IPv4 sequence
 *	============================
 */


-- Create a temptable with a sequence of IPv4,
-- from ip_min to ip_max (which are strings representing IPs).
-- Note about testing:
-- IPs are sorted as strings! so, to test properly, use:
-- CALL create_ip_sequence('10.0.5.9', '10.0.6.9');
-- SELECT COUNT(*), INET_NTOA(MIN(INET_ATON(ip))), INET_NTOA(MAX(INET_ATON(ip))) FROM ip_list;


DROP PROCEDURE IF EXISTS create_ip_sequence;
CREATE PROCEDURE create_ip_sequence(IN ip_min VARCHAR(15), IN ip_max VARCHAR(15))
	MODIFIES SQL DATA
	COMMENT 'Create a temptable with an IPv4 sequence'
BEGIN
	DROP TABLE IF EXISTS ip_list;
	CREATE TABLE ip_list
	(
		ip VARCHAR(15) NOT NULL
	) ENGINE = MEMORY;
	
	SET @__sql = CONCAT(
			'INSERT INTO ip_list ',
			'SELECT INET_NTOA(seq) FROM seq_', INET_ATON(ip_min), '_to_', INET_ATON(ip_max)
		);
	PREPARE __stmt FROM @__sql;
	EXECUTE __stmt;
	
	DEALLOCATE PREPARE __stmt;
	SET @__sql = NULL;
END;


/*
 *	SEQUENCE.006 - Multiples
 *	========================
 */


-- Find multiples of 3, minor than 100
SELECT seq FROM seq_3_to_100_step_3;

-- Multiples of both 3 and 5
SELECT s1.seq
	FROM seq_5_to_100_step_5 s1
	INNER JOIN seq_3_to_100_step_3 s2
	ON s1.seq = s2.seq;

-- Multiples of 24, between 500 and 600
SELECT seq FROM seq_500_to_600 WHERE seq MOD 24 = 0;


/*
 *	SEQUENCE.007 - Multiple of 2 or its powers
 *	==========================================
 */


SELECT seq FROM seq_1_to_100 WHERE NOT seq & 1;  -- ...of 2
SELECT seq FROM seq_1_to_100 WHERE NOT seq & 3;  -- ...of 4
SELECT seq FROM seq_1_to_100 WHERE NOT seq & 7;  -- ...of 8
SELECT seq FROM seq_1_to_100 WHERE NOT seq & 15; -- ...of 16


/*
 *	SEQUENCE.008 - Squares & Cubes
 *	==============================
 */


SELECT seq * seq AS s, POW(seq, 3) AS c FROM seq_1_to_10;


/*
 *	SEQUENCE.009 - -- Partial sums
 *	==============================
 */


SET @part = 0;
SELECT (@part := @part + seq) AS part FROM seq_1_to_10;


/*
 *	SEQUENCE.009 - Triangular numbers
 *	=================================
 */


SELECT CAST(seq * (seq + 1) / 2 AS UNSIGNED) FROM seq_1_to_10;


/*
 *	SEQUENCE.010 - Triangular numbers
 *	=================================
 */


-- Copied from: https://kb.askmonty.org/en/sequence/


SELECT seq FROM seq_1_to_50 s1 WHERE 0 NOT IN
	(SELECT s1.seq % s2.seq FROM seq_2_to_50 s2 WHERE s2.seq <= SQRT(s1.seq));


/*
 *	SEQUENCE.011 - Factorials
 *	=========================
 */


-- Factorials sequence


SELECT IF(seq < 2, (@fact := 1), (@fact := @fact * seq)) AS fact FROM seq_0_to_10;

-- 5!
SELECT MAX(IF(seq < 2, (@fact := 1), (@fact := @fact * seq))) AS fact FROM seq_1_to_5;


/*
 *	SEQUENCE.012 - Rising Factorials, Falling Factorials
 *	====================================================
 */


-- Rising Factorial sequence: all 5 RF's up to 5(4)
SET @x = 5;
SELECT seq, @rise_fact := IF(seq = 1, @x, @rise_fact * (@x + seq - 1)) AS rise_fact FROM seq_1_to_4;

-- Only get 5(4)
SET @x = 5;
SELECT MAX(@rise_fact := IF(seq = 1, @x, @rise_fact * (@x + seq - 1))) AS rise_fact FROM seq_1_to_4;

-- Falling Factorial: up to 5(4)
SET @x = 5;
SELECT seq, @rise_fact := IF(seq = 1, @x, @rise_fact * (@x - seq + 1)) AS rise_fact FROM seq_1_to_4;


/*
 *	SEQUENCE.013 - Fibonacci series
 *	===============================
 */


-- Fibonacci series up to 11th number (from 0)
SELECT
		seq,
		IF(seq = 0, 0, IF(seq = 1,
			(@a := 0) + (@b := 1) + (@s := 0),
			(@b := LAST_VALUE(LAST_VALUE(@s := (@a + @b), @a := @b), @s))
		)) AS fibo
	FROM seq_0_to_10;

-- 10th Fibonacci number (starting from 0)
SELECT
		MAX(IF(seq = 0, 0, IF(seq = 1,
			(@a := 0) + (@b := 1) + (@s := 0),
			(@b := LAST_VALUE(LAST_VALUE(@s := (@a + @b), @a := @b), @s))
		))) AS fibo
	FROM seq_0_to_10;


/*
 *	SEQUENCE.014 - Fermat numbers
 *	=============================
 */


-- First 5 Fermat numbers
-- (You cannot go further, cause 6th number exceedes BIGINT)
SELECT seq, POW(2, POW(2, seq)) + 1 AS fermat FROM seq_1_to_5;


/*
 *	SEQUENCE.015 - Carol numbers
 *	============================
 */


SELECT seq, (POW(4, seq) - POW(2, seq + 1) - 1) AS carol FROM seq_1_to_10;


/*
 *	SEQUENCE.016 - Kynea numbers
 *	============================
 */


SELECT seq, (POW(4, seq) + POW(2, seq + 1) - 1) AS kynea FROM seq_1_to_10;


/*
 *	SEQUENCE.017 - Ordered Integer Lists
 *	====================================
 */


-- Create a table containing ordered integer lists
-- (id determines the order)
-- 1,  1,2,  1,2,3  1,2,3,4,  1,2,3,4,5,  ...
DROP PROCEDURE IF EXISTS create_sublists;
CREATE PROCEDURE create_sublists(IN maxnum INTEGER UNSIGNED)
	MODIFIES SQL DATA
	COMMENT 'Create a table with a fractal sequence'
BEGIN
	DECLARE x INTEGER UNSIGNED DEFAULT 1;
	
	DROP TABLE IF EXISTS sublists;
	CREATE TABLE sublists
	(
		id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
		seq INTEGER UNSIGNED NOT NULL
	) ENGINE = MEMORY;
	
	WHILE x <= maxnum DO
		SET @__sql = CONCAT('INSERT INTO sublists(seq) SELECT seq FROM seq_1_to_', x, ';');
		PREPARE __stmt FROM @__sql;
		EXECUTE __stmt;
		
		SET x = x + 1;
	END WHILE;
	
	SET @__sql = NULL;
	DEALLOCATE PREPARE __stmt;
END;


/*
 *	SEQUENCE.018 - 1-char strings
 *	=============================
 */


-- Sequence of 1-char strings
SELECT CHAR(seq) AS ch
    FROM (
                -- lowercase
                (SELECT seq FROM seq_97_to_122 l)
            UNION
                -- uppercase
                (SELECT seq FROM seq_65_to_90 u)
            UNION
                -- digits
                (SELECT seq FROM seq_48_to_57 d)
        ) ch;


/*
 *	SEQUENCE.019 - 2-char strings
 *	=============================
 */


-- Build a sequence of 2-char strings
-- (this UNION is tricky, but someone could still use it)
SELECT CONCAT(ch1.ch1, ch2.ch2) AS ch
    FROM (
        (SELECT CHAR(seq) AS ch1
            FROM (
                        -- lowercase
                        (SELECT seq FROM seq_97_to_122 l1)
                    UNION
                        -- uppercase
                        (SELECT seq FROM seq_65_to_90 u1)
                    UNION
                        -- digits
                        (SELECT seq FROM seq_48_to_57 d1)
                ) s1
        )
    ) ch1
    CROSS JOIN (
        (SELECT CHAR(seq) AS ch2
            FROM (
                        -- lowercase
                        (SELECT seq FROM seq_97_to_122 l2)
                    UNION
                        -- uppercase
                        (SELECT seq FROM seq_65_to_90 u2)
                    UNION
                        -- digits
                        (SELECT seq FROM seq_48_to_57 d2)
                ) s2
        )
    ) ch2
    ORDER BY ch1, ch2;


/*
 *	SEQUENCE.020 - Sequence of dates
 *	================================
 */


SELECT DATE ('2014.01.01' + INTERVAL (s.seq - 1) DAY) AS d
    FROM (SELECT seq FROM seq_1_to_30) s;


/*
 *	SEQUENCE.021 - Sequence of time
 *	===============================
 */


-- Hours in a day
SELECT CAST('00:00:00' AS TIME) + INTERVAL (s.seq - 1) HOUR AS t
    FROM (SELECT seq FROM seq_1_to_24) s;

-- Halfes of an hour in a day
SELECT CAST('00:00:00' AS TIME) + INTERVAL (30 * s.seq) MINUTE AS t
    FROM (SELECT seq FROM seq_1_to_48) s;


/*
 *	SEQUENCE.022 - Working days
 *	===========================
 */


SELECT DATE ('2014-01-01' + INTERVAL (s.seq - 1) DAY) AS d
    FROM (SELECT seq FROM seq_1_to_30) s
    -- exclude sunday (1) and saturday (7)
    WHERE DAYOFWEEK(DATE ('2014-01-01' + INTERVAL (s.seq - 1) DAY)) BETWEEN 2 AND 6;


/*
 *	SEQUENCE.023 - Working hours
 *	============================
 */


SELECT {dt '2013-01-01 01:00:00'} + INTERVAL (wd.d - 1) DAY + INTERVAL (dh.h - 1) HOUR AS wh
    FROM
        (
            -- working days in a month
            SELECT seq AS d FROM seq_1_to_30
        ) wd
    CROSS JOIN
        (
            -- daily working hours
            (SELECT seq AS h FROM seq_9_to_12)
            UNION
            (SELECT seq AS h FROM seq_14_to_17)
        ) dh
    ORDER BY 1;
