CREATE OR REPLACE LUA SCRIPT "PROFILING" () RETURNS ROWCOUNT AS
import("SQLPROFILE", 'sqlprofile')

sqlparsing.setsqltext(
        sqlprofile.explain(sqlparsing.getsqltext()))
/
