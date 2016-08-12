package ormtest.model10
{

    [Bindable]
    [Table(name = "sys_user10")]
    public class User10
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
        [ArrayElementType("ormtest.model10.RoleGroup10")]
        [ManyToMany(type = "ormtest.model10.RoleGroup10", table = "sys_user_group10", joinColumns = "[joinColumnName ='sys_user_id', blablub = 'haha'] "
                                    , inverseJoinColumns = "[joinColumnName = 'permissions_id']", lazy = "false")]
        [ForeignKey(name = "FK_USER10_ROLEGROUP10_")]
        public var permissions:ArrayCollection;
    }
}
