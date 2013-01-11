package m.io.queue {
	/**
	 * Implements a generic queue to help synchronizing asynchron operations.
	 * 
	 * @author Tom Hanoldt
	 */
	public class QueueAbstract {
		protected var queue:Array = [];
		/** 
		 * Get the length of the queue. 
		 * 
		 * @return int Length of queue.
		 */
		public function get length():int {
			return queue.length;
		}
		
		/** 
		 * Add a Item to the queue.
		 * 
		 * @param instance The item to be enqueued.
		 * @param process Indicats if to start processing the queue after enqueuing the item.
		 * 
		 * @return void
		 */
		public function enqueue(instance:*, process:Boolean = true):void {
			queue.push(instance);
			if(process)
				processQueue();
		}
		
		protected var queueIsWorking:Boolean = false;
		/** 
		 * Get information about weather the queue is actually working or not.
		 * 
		 * @return Boolean True if queue is working, false otherwise.
		 */
		public function get isWorking():Boolean {
			return queueIsWorking;
		}
		
		/** 
		 * This method checks if the queue can process the next item.
		 * 
		 * @param force Tell if to force the queue.
		 * 
		 * @return Boolean
		 */
		protected function checkCanProcessQueue(force:Boolean = false):Boolean {
			return (queue.length 
				&& (force || !queueIsWorking)) 
		}
		
		/** 
		 * This method processes the next item in the queue.
		 * 
		 * @param force Tell if to force thee queue to process the next item-
		 * 
		 * @return void
		 */
		public function processQueue(force:Boolean = false):void {
			if (!checkCanProcessQueue(force)) 
				return ;
				
			executeQueueJob(
				transformQueueItemToFunction(
					queue.shift()));
		}
		
		/** 
		 * This method is used to transform a queue item to a method that can be executet.
		 * 
		 * @param instance The queue item.
		 * 
		 * @return Function A method that cann be executet.
		 */
		protected function transformQueueItemToFunction(instance:*):Function {
			throw new Error('m.io.QueueAbstract::transformQueueItemToFunction not implemented');
		}
		
		/** 
		 * This method executes a method and catches thrown erros, so the queue doesnt stop.
		 * 
		 * @param job The method representing a job mapped to a queue item.
		 * 
		 * @return void
		 */
		protected function executeQueueJob(job:Function):void {
			queueIsWorking = true;
			try {
				job();
			}catch (e:Error) {
				jobFinished();
			}
		}
		
		/** 
		 * This method should be called if a queue job is finished so the queue can process the next item.
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		public function queueCallback(callback:Function = null, param:* = null):void {
			if (callback != null) {
				if (param != null) callback(param);
				else callback();
			}
			jobFinished();
		}
		
		/** 
		 * This method set the queue state to not working and starts processing of the next item.
		 * 
		 * @param e blalba
		 * 
		 * @return void
		 */
		public function jobFinished():void {
			queueIsWorking = false;
			processQueue();
		}
	}
}