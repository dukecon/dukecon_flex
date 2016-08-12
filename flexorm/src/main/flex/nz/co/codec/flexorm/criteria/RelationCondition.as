package nz.co.codec.flexorm.criteria
{
    public class RelationCondition extends ParameterisedCondition
    {
        private var _relation:String;
        private var _negated: Boolean;

        public function RelationCondition(table:String, column:String, relation:String, param:String, negated: Boolean = false)
        {
            _relation = relation;
            _negated = negated;
            super(table, column, param);
        }

        override public function toString():String
        {
            return (_negated ? "NOT " : "") + column + _relation + ":" + param;
        }
    }
}
