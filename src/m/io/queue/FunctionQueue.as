package m.io.queue {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class FunctionQueue extends QueueAbstract {
		override public function enqueue(f:*):void {
			super.enqueue(f as Function);
		}
		
		override protected function transformQueueItemToFunction(instance:*):Function {
			return (instance as Function);
		}
	}
}