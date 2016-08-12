package ormtest.model4
{
    [Bindable]
    [Table(name = "vuser4", isView = "true")]
    public class UserLightView4 
    {
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

    }
}
