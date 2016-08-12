package ormtest.model4
{

    [Bindable]
    [Table(name = "sys_user4")]
    public class User4 
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
        [ArrayElementType("ormtest.model4.RoleGroup4")]
        [ManyToMany(type = "ormtest.model4.RoleGroup4", table = "sys_user_group4", joinColumns = "[joinColumnName ='sys_user_id', blablub = 'haha'] "
                                    , inverseJoinColumns = "[joinColumnName = 'permissions_id']", lazy = "false")]
        [ForeignKey(name = "FK_USER4_ROLEGROUP4_")]
        public var permissions:ArrayCollection;
    }
}
