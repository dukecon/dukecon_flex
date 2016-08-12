package ormtest.model
{
    import mx.collections.IList;

    import ormtest.model2.Person;

    [Bindable]
    [Table(name="my_friends", inheritsFrom="ormtest.model2.Person")]
    public class Contact extends Person
    {
        private var _orders:IList;

        [Id]
        [Column(name="my_contact_id")]
        override public var id:int;

        [Column(name="name")]
        public var name:String;

//		public var another:String;

        [ManyToOne(cascade="none")]
        public var organisation:Organisation;

        [OneToMany(type="ormtest.model.Order", fkColumn="my_contact_id", cascade="save-update", constrain="false", lazy="false", indexed="true")]
        public function set orders(value:IList):void
        {
            _orders = value;
            for each(var order:* in value)
            {
                order.contact = this;
            }
        }

        public function get orders():IList
        {
            return _orders;
        }

        [ManyToMany(type="ormtest.model.Role", indexed="true")]
        public var roles:IList;

    }
}