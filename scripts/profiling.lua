OPEN SCHEMA MICRO;
CREATE OR REPLACE LUA SCRIPT "PROFILING" () RETURNS ROWCOUNT AS
import("MICRO.SQLPROFILE", 'sqlprofile')

sqlparsing.setsqltext(
        sqlprofile.explain(sqlparsing.getsqltext()))
/