package ormtest.model12
{

    [Bindable]
    [Table(name = "key_owner12")]
    public class KeyOwner12
    {
        /**
         * The ID field.
         */
        [Id]
        [Column(name = "ownerid")]
        public var id:int;

        [Column(name = "ownername")]
        public var name:String;
    }
}
