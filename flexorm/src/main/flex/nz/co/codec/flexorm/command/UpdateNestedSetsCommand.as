package nz.co.codec.flexorm.command
{
    import flash.data.SQLConnection;

    import mx.utils.StringUtil;

    public class UpdateNestedSetsCommand extends SQLParameterisedCommand
    {
        public function UpdateNestedSetsCommand(sqlConnection:SQLConnection, schema:String, table:String, debugLevel:int=0)
        {
            super(sqlConnection, schema, table, debugLevel);
            
            var sql:String = StringUtil.substitute("update {0}.{1} set lft=lft+:inc,rgt=rgt+:inc where lft>:lft and rgt<:rgt;", schema, table);
            sql += SQL_STATEMENT_SEPARATOR;
            _statement.text = sql;
        }

        public function toString():String
        {
            return "UPDATE NESTED SETS " + _table + ": " + getStatementText();
        }

    }
}