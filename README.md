# EXASOL Explain

A quick way to see the profile information for your queries in EXASOL.

If you need more details about profiling you can check the Profiling chapter on the [EXASOL manual](https://www.exasol.com/support/secure/attachment/37661/EXASolution_User_Manual-5.0.12-en.pdf). 

## Install

Grab the scripts in the scripts folder and run them on you EXASOL. 

## How to Use It

### explain

    explain select * from my_table;

It's enough to put `explain` in front of any of your queries and in the output window will appear the profiling information for your query.

**Note** EXASOL need to run the query to show profiling info, so if your query modifies objects or data, they will be changed.

### explain_this(session_id, statement_id)

    explain_this(32768649837094, 312)

If you need to display information for a query you were profiling in the last 24 hours, you can use `explain_this` to see it. 

Profiling information are stored by EXASOL only for the last 24 hours.




##Why this

EXASOL is parallelized RDBMS, it is very fast and doesn't really need much tuning, but for these same reasone people tend to load it with huge amount of data, thinking that the database will be fast anyway. It will, but it can do much better.

Because queries run on multiple nodes, EXASOL doens't provide a query plan (like Oracle does) before running a query, the closest thing to a query plan is the post-execution query profile. To get it you should:

    -- enable profiling
    ALTER SESSION SET profile='ON';
    -- run query
    SELECT YEAR(o_orderdate) AS "YEAR", COUNT(*)
    FROM orders
    GROUP BY YEAR(o_orderdate)
    ORDER BY 1 LIMIT 5;
    -- switch off profiling again and avoid transaction conflicts
    ALTER SESSION SET profile='OFF';
    COMMIT;
    -- provide newest information and open new transaction
    FLUSH STATISTICS;
    COMMIT;
    -- read profiling information
    SELECT part_id, part_name, object_name, object_rows, out_rows, duration
    FROM exa_user_profile_last_day
    WHERE CURRENT_STATEMENT-5 = stmt_id;

I found this cumbersome and I started to work on easy way to get the profile of my queries.


##License
This is released under the whatever license.
