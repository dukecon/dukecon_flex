package ormtest.model7
{

    [Bindable]
    [Table(name = "sys_user7")]
    public class User7
    {
        import mx.collections.ArrayCollection;

        /**
         * The ID field.
         */
        [Id(strategy = "assigned")]
        [Column(name = "id")]
        public var id:Number;

        /**
         * username.
         */
        [Column(name = "username", length = 50)]
        public var username:String;

        /**
         * permissions.
         */
        [ArrayElementType("ormtest.model7.RoleGroup7")]
        [ManyToMany(type = "ormtest.model7.RoleGroup7", table = "sys_user_group7", joinColumns = "[joinColumnName = 'sys_user_id']"
                                    , inverseJoinColumns = "[joinColumnName = 'permissions_id']", lazy = "false")]
        [ForeignKey(name = "FK_USER7_ROLEGROUP7_")]
        public var permissions:ArrayCollection;
    }
}
