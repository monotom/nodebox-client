package m.io.queue {
	/**
	 * An implmenetation of the QueueAbstract with type cheks for elemnts from type Function in the queue. @see QueueAbstract
	 * 
	 * @author Tom Hanoldt
	 */
	public class FunctionQueue extends QueueAbstract {
		/** 
		 * This method enqueues a function into the queue.
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		override public function enqueue(f:*, process:Boolean = true):void {
			super.enqueue(f as Function, process);
		}
		
		/** 
		 * This method transforms a queue item to a function. In this case it s done via casting.
		 * 
		 * @param instance The item to transform.
		 * 
		 * @return void
		 */
		override protected function transformQueueItemToFunction(instance:*):Function {
			return (instance as Function);
		}
	}
}