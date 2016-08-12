package nz.co.codec.flexorm.criteria
{

    public class EqualsCondition extends RelationCondition
    {
        public function EqualsCondition(table:String, column:String, param:String)
        {
            super(table, column, "=", param);
        }
        }

}
