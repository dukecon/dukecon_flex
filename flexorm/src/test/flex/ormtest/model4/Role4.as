package ormtest.model4
{

    [Bindable]
    [Table(name = "sys_role4")]
    public class Role4
    {
        /**
         * The ID field.
         */
        [Id(strategy = "assigned")]
        [Column(name = "id")]
        public var id:Number;

        /**
         * name.
         */
        [Column(name = "name", length = 30)]
        public var roleName:String;
    }
}
