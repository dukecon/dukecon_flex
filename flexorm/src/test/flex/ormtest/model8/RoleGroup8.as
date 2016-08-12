package ormtest.model8
{

    [Bindable]
    [Table(name = "sys_group8")]
    public class RoleGroup8
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
