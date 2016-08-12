package ormtest.model12
{

    [Bindable]
    [Table(name = "room12")]
    public class Room12
    {
        /**
         * The ID field.
         */
        [Id]
        [Column(name = "roomid")]
        public var id:int;

        /**
         * The rooms description.
         */
        [Column(name = "description")]
        public var description:String;
		
        /**
         * Who has the key?
         */
        [ManyToOne(name="keyOwner_id")]
        public var keyOwner:KeyOwner12;
	}
}
