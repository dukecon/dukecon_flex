package ormtest.model12
{

    [Bindable]
    [Table(name = "book12")]
    public class Book12
    {
        /**
         * The ID field.
         */
        [Id(strategy = "assigned")]
        [Column(name = "bookid")]
        public var id:int;

        /**
         * The books title.
         */
        [Column(name = "booktitle")]
        public var title:String;

        /**
         * Where is it?
         */
        [ManyToOne(name="location_id")]
        public var location:Room12;
    }
}
