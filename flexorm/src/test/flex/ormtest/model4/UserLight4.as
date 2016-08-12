package ormtest.model4
{

    [Bindable]
    [Table(name = "vuser4", createTable="false", indexed="false", constrain="false")]
    public class UserLight4 
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
