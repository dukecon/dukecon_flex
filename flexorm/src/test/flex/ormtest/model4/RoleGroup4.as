package ormtest.model4
{

    [Bindable]
    [Table(name = "sys_group4")]
    public class RoleGroup4
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
        [ArrayElementType("ormtest.model4.Role4")]
        // NOTE: default column name definition differs from Hibernate, so define it explicitly
        [ManyToMany(type = "ormtest.model4.Role4", table = "sys_group_role4", joinColumns = "[joinColumnName = 'sys_group_id']"
                                    , inverseJoinColumns = "[joinColumnName = 'roles_id']", lazy = "false")]
        [ForeignKey(name = "FK_ROLEGROUP4_ROLE4_")]
        public var roles:ArrayCollection;
    }
}
