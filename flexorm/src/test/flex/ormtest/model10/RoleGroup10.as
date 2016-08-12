package ormtest.model10
{

    [Bindable]
    [Table(name = "sys_group10")]
    public class RoleGroup10
    {
        import mx.collections.ArrayCollection;

        /**
         * The ID field.
         */
        [Id(strategy = "assigned")]
        [Column(name = "id")]
        public var id:Number;

        /**
         * name.
         */
        [Column(name = "name", nullable = false)]
        public var roleGroupName:String;
    }
}
