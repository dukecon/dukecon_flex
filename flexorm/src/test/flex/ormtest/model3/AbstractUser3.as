package ormtest.model3
{
    [Bindable]
    [MappedSuperclass]
    public class AbstractUser3
    {
		/**
         * The ID field.
         */
        [Id(strategy = "assigned")]
        [Column(name = "id")]
        public var id:int;

        /**
         * lastName.
         */
        [Column(name = "last_name")]
        public var lastName:String;

        /**
         * firstName.
         */
        [Column(name = "first_name")]
        public var firstName:String;

        /**
         * active
         */
        [Column(name = "active", nullable = "false")]
        public var active:Boolean;
    }
}
