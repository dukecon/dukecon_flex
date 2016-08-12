package ormtest.model
{
	[Bindable]
	public class Year
	{
		[Id(strategy="assigned")]
		public var year:int;

	}
}