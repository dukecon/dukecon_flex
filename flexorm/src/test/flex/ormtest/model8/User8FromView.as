package ormtest.model8
{

    [Bindable]
    [Table(name = "sys_user8")]
    public class User8FromView
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
        [ArrayElementType("ormtest.model8.RoleGroup8")]
        [ManyToMany(type = "ormtest.model8.RoleGroup8", table = "vSYS_USER_GROUP8", tableIsView="true" ,joinColumns = "[joinColumnName = 'sys_user_id_fromView']"
                                    , inverseJoinColumns = "[joinColumnName = 'permissions_id_fromView']", lazy = "false")]
        [ForeignKey(name = "FK_USER8_ROLEGROUP8_")]
        public var permissions_fromView:ArrayCollection;
    }
}
