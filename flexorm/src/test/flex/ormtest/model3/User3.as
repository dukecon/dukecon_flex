package ormtest.model3
{

    [Bindable]
    [Table(name = "sys_user3")]
    public class User3 extends AbstractUser3
    {
        /**
         * username.
         */
        [Column(name = "username", nullable = "false")]
        public var username:String;
        
        /**
         * lastUpdateUser.
         */
        [ManyToOne(name = "last_update_user", constrain = "false")]
        //		[ForeignKey(name = "FK_USER_USER_")]
        public var lastUpdateUser:UserLight3;

    }
}
