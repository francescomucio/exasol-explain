OPEN SCHEMA MICRO;
CREATE OR REPLACE LUA SCRIPT "SQLPROFILE" () RETURNS ROWCOUNT AS
function explain(sqltext)

          sqltext =  sqltext:match( "^%s*(.-)%s*$" ) 
          if (string.upper(string.sub(sqltext, 1, 7)) ~= 'EXPLAIN') then
             return sqltext
          end

          if (string.upper(string.sub(sqltext, 1, 8)) == 'EXPLAIN ') then
             explainQuery = explain_sql(string.sub(sqltext, 9))

             return explainQuery
          end 

          if (string.match(string.upper(sqltext), "EXPLAIN_THIS%s*%(%s*(%d+)%s*,%s*(%d+)%s*%).*") ~= nil) then

             for session_id, stmt_id in string.gmatch(string.upper(sqltext), "EXPLAIN_THIS%s*%(%s*(%d+)%s*,%s*(%d+)%s*%).*") do
             		explainQuery = profileQuery(session_id, stmt_id)
             end

             return explainQuery

          end 
          
		  return sqltext          
   
   end

   -- To match explain, EXPLAIN, Explain, ExPlAiN or whatever
   function explain_match(token)
          if (string.upper(token)=='EXPLAIN') then
              return true
          end
          return false
   end

   function explain_sql(sqltext) 
           pquery([[ALTER SESSION SET PROFILE = 'ON']])
           pquery(sqltext) 
           pquery([[ALTER SESSION SET PROFILE = 'OFF']])
           pquery([[COMMIT;]])
           pquery([[FLUSH STATISTICS;]])
           pquery([[COMMIT;]])
           local success, res = pquery[[select to_char(current_session), current_statement;]]

		   profileCheckQuery = profileQuery(res[1][1], res[1][2] - 5)
  		  -- profileCheckQuery = "select to_char(" .. res[1][1] .. ");"
           --profileCheckQuery = 'select ' .. profileQuery(res[1][1], res[1][2] - 6)

           return profileCheckQuery
   end

   function profileQuery(session_id, stmt_id)

          query = [[            select * 
				                  from EXA_USER_PROFILE_LAST_DAY 
					             where stmt_id = PLACEHOLDER_STATEMENT_ID
					               and session_id = PLACEHOLDER_SESSION_ID

                             union all
                                select session_id, 
                                       stmt_id,
                                       'Summary' command_name,
                                       command_class,
                                       999999 part_id, 
                                       null part_name,
                                       null part_info,
                                       null object_schema,
                                       null object_name,
                                       null object_rows,
                                       null out_rows,
                                       sum(duration) duration,
                                       max(cpu) cpu,
                                       max(temp_db_ram_peak) temp_db_ram_peak,
                                       sum(hdd_read * duration) hdd_read,
                                       sum(hdd_write * duration) hdd_write,
                                       sum(net * duration) net,
                                       null remarks,
                                       null sql_text
				                  from EXA_USER_PROFILE_LAST_DAY 
					             where stmt_id = PLACEHOLDER_STATEMENT_ID
					               and session_id = PLACEHOLDER_SESSION_ID
                              group by session_id, 
                                       stmt_id,
                                       command_class
                              order by part_id]]

          query = string.gsub(query, 'PLACEHOLDER_STATEMENT_ID', stmt_id)
          query = string.gsub(query, 'PLACEHOLDER_SESSION_ID', session_id)

          return query
   end
/