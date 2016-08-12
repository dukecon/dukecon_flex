package ormtest.model3
{
    [Bindable]
    [Table(name = "sys_user3")]
    public class UserLight3 extends AbstractUser3
    {
        /**
         * lastUpdateUser.
         */
        [Column(name = "last_update_user", nullable = "false")]
        public var lastUpdateUserId:Number;
    }
}
