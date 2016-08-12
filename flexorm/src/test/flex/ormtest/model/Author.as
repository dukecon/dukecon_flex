package ormtest.model
{
	import mx.collections.IList;
	
	[Bindable]
	[Table(name='Authors')]
	public class Author
	{
		[Id]
		[Column(name='author_id')]
		public var id:int;
		public var firstName:String;
		public var lastName:String;
		
		[ManyToMany(type='ormtest.model.Book', table='testtable')]
		public var books:IList;
	}
}