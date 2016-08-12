package nz.co.codec.flexorm.command
{
    import flash.data.SQLConnection;
    import flash.events.SQLEvent;

    public class SelectMaxRgtCommand extends SQLCommand
    {
        private var _result:Array;

        public function SelectMaxRgtCommand(sqlConnection:SQLConnection, schema:String, table:String, debugLevel:int=0)
        {
            super(sqlConnection, schema, table, debugLevel);

            var sql:String = "select max(rgt) as max_rgt from " + schema + "." + table + ";";
            sql += SQL_STATEMENT_SEPARATOR;
            _statement.text = sql;
        }

        override public function execute():void
        {
            super.execute();
            if (_responder == null)
                _result = _statement.getResult().data;
        }

        override protected function respond(event:SQLEvent):void
        {
            _result = _statement.getResult().data;
            _responder.result(_result);
        }

        public function get result():Array
        {
            return _result;
        }

        public function getMaxRgt():int
        {
            return (_result && _result.length > 0) ? _result[0].max_rgt : 0;
        }

        public function toString():String
        {
            return "SELECT MAX RGT: " + getStatementText();
        }

    }
}