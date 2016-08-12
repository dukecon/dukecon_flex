package ormtest.model
{
	[Bindable]
	[Table(name='Books')]
	public class Book
	{
		[Id]
		[Column(name='book_id')]
		public var id:int;
		public var name:String;
	}
}