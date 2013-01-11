package{
	/**
	 * This is a Dummy class.
	 * @author Tom Hanoldt
	 */
	public class Dummy {
		
		/**
		 * This is a dummy proprty.
		 */
		public var dummyProperty:String = 'dummy';
		
		/**
		 * This is a dummy method
		 * @param	items Dummy items.
		 */
		public function dummyMethod(itemsOrItem:Object = null):void{
			if (items == null) //watchdog
				return ;
				
			for each(var item:Object in items)
				dummyMethod(item);
		}		
	}
}