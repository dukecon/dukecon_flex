package nz.co.codec.flexorm.command
{
    import flash.data.SQLConnection;

    import mx.utils.StringUtil;

    public class ConstraintInsertTriggerCommand extends SQLCommand
    {
        public function ConstraintInsertTriggerCommand(
            sqlConnection:SQLConnection,
            schema:String,
            table:String,
            column:String,
            constraintTable:String,
            constraintColumn:String,
            debugLevel:int=0)
        {
            super(sqlConnection, schema, table, debugLevel);

            var sql:String = StringUtil.substitute("create trigger fki_{1}_{2} before insert on {0}.{1} for each row begin select raise(rollback, 'insert on table \"{1}\" violates foreign key constraint \"fki_{1}_{2}\"') where new.{2} is not null and new.{2}<>0 and (select t.{4} from {0}.{3} t where t.{4}=new.{2}) is null; end;",
                schema, table, column, constraintTable, constraintColumn);
            sql += SQL_STATEMENT_SEPARATOR;
            _statement.text = sql
        }

        public function toString():String
        {
            return "CREATE FK CONSTRAINT INSERT TRIGGER: " + getStatementText();
        }

    }
}