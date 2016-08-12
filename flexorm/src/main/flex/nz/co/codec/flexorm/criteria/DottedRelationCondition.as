package nz.co.codec.flexorm.criteria
{

    public class DottedRelationCondition extends RelationCondition
    {
        private var _joins:Object;

        public function DottedRelationCondition(table:String, column:String, joins:Object, relation:String, param:String, negated:Boolean = false)
        {
            _joins = joins;

            super(table, column, relation, param, negated);
        }

        public function get joins():Object
        {
            return _joins;
        }
    }
}
