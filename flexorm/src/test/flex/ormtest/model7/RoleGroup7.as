package ormtest.model7
{

    [Bindable]
    [Table(name = "sys_group7")]
    public class RoleGroup7
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

        /**
         * roles.
         */
        [ArrayElementType("ormtest.model7.Role7")]
        // NOTE: default column name definition differs from Hibernate, so define it explicitly
        [ManyToMany(type = "ormtest.model7.Role7", table = "sys_group_role7", joinColumns = "[joinColumnName = 'sys_group_id']"
                                    , inverseJoinColumns = "[joinColumnName = 'roles_id']", lazy = "false")]
        [ForeignKey(name = "FK_ROLEGROUP7_ROLE7_")]
        public var roles:ArrayCollection;
    }
}
