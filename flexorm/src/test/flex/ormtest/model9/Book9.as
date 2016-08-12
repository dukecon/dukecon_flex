package ormtest.model9
{
	[Bindable]
	[Table(name='Book9')]
	public class Book9
	{
		[Id]
		[Column(name='book_id')]
		public var id:int;
		
		public var name:String;
		
		public var price: Number;
		
		public var published: Date;
	}
}