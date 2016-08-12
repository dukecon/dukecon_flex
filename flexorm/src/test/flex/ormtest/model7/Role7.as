package ormtest.model7
{

    [Bindable]
    [Table(name = "sys_role7")]
    public class Role7
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
