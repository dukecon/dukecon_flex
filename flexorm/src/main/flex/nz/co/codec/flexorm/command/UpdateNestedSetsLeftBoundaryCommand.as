package nz.co.codec.flexorm.command
{
    import flash.data.SQLConnection;

    import mx.utils.StringUtil;

    public class UpdateNestedSetsLeftBoundaryCommand extends SQLParameterisedCommand
    {
        public function UpdateNestedSetsLeftBoundaryCommand(sqlConnection:SQLConnection, schema:String, table:String, debugLevel:int=0)
        {
            super(sqlConnection, schema, table, debugLevel);
            
            var sql:String = StringUtil.substitute("update {0}.{1} set lft=lft+:inc where lft>=:lft;", schema, table);
            sql += SQL_STATEMENT_SEPARATOR;
            _statement.text = sql;
        }

        public function toString():String
        {
            return "UPDATE NESTED SETS LEFT BOUNDARY " + _table + ": " + getStatementText();
        }

    }
}