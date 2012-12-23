package m.io.queue {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class QueueAbstract {
		protected var queue:Array = [];
		public function get length():int {
			return queue.length;
		}
		
		public function enqueue(instance:*):void {
			queue.push(instance);
			processQueue();
		}
		
		protected var queueIsWorking:Boolean = false;
		public function get isWorking():Boolean {
			return queueIsWorking;
		}
		
		protected function checkCanProcessQueue(force:Boolean = false):Boolean {
			return (queue.length 
				&& (force || !queueIsWorking)) 
		}
		
		public function processQueue(force:Boolean = false):void {
			if (!checkCanProcessQueue(force)) 
				return ;
				
			executeQueueJob(
				transformQueueItemToFunction(
					queue.shift()));
		}
		
		protected function transformQueueItemToFunction(instance:*):Function {
			throw new Error('m.io.QueueAbstract::transformQueueItemToFunction not implemented');
		}
		
		protected function executeQueueJob(job:Function):void {
			queueIsWorking = true;
			try {
				job();
			}catch (e:Error) {
				jobFinished();
			}
		}
		
		public function queueCallback(callback:Function = null, param:* = null):void {
			if (callback != null) {
				if (param != null) callback(param);
				else callback();
			}
			jobFinished();
		}
		
		public function jobFinished():void {
			queueIsWorking = false;
			processQueue();
		}
	}
}