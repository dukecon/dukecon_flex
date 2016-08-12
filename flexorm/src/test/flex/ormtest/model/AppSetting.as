package ormtest.model
{
	[Bindable]
	public class AppSetting
	{
		[Id(strategy="assigned")]
		public var name:String;

		public var value:String;

	}
}