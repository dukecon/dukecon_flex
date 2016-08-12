package nz.co.codec.flexorm.criteria
{

    public class SQLFunction extends SQLCondition implements ICondition
    {
        import mx.utils.StringUtil;

        public static const TABLENAME_PLACEHOLDER:String = ";;TABLENAME_PLACEHOLDER;;";

        public function SQLFunction(table:String, sql:String)
        {
            super(table, sql);
        }

        public function getString(tableIndex:int):String
        {
            return StringUtil.substitute(this.toString().replace(TABLENAME_PLACEHOLDER, "t{0}"), tableIndex);
        }
    }
}
