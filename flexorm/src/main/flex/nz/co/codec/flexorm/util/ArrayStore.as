package nz.co.codec.flexorm.util
{
	
	public class ArrayStore
	{
		import mx.rpc.IResponder;
		import mx.rpc.Responder;
		import nz.co.codec.flexorm.EntityEvent;
		import nz.co.codec.flexorm.EntityManager;
		import nz.co.codec.flexorm.EntityManagerAsync;
		
		public static function saveAsync(em:EntityManagerAsync, array:Array, responder:IResponder):void
		{
			var i:int = 0;
			var resultArray:Array = new Array(array.length);
			
			saveNextArrayElement();
			
			function saveNextArrayElement():void
			{
				em.save(array[i], new Responder(onNextArrayElementSaved, responder.fault));
			}
			
			function onNextArrayElementSaved(ev:EntityEvent = null):void
			{
				resultArray[i] = ev.data;
				i++;
				
				if (i < array.length)
				{
					saveNextArrayElement();
				}
				else
				{
					responder.result(new EntityEvent(resultArray));
				}
			}
		}
		
		public static function saveSync(em:EntityManager, array:Array):void
		{
			for (var i:int = 0; i < array.length; i++)
			{
				em.save(array[i]);
			}
		}
	}
}
