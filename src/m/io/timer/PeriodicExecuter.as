package m.io.timer {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * A simple extension from the flash.util.Timer class so that a method would be called periodically.
	 * @author Tom Hanoldt
	 */
	public class PeriodicExecuter extends Timer {
		protected var period:Number;
		protected var callback:Function;
		/** 
		 * Cosntructor
		 * 
		 * @param period Period of timer events in Seconds.
		 * @param callback The mehtod called periodically.
		 * @param start Indicates if to start the timer imidiatly.
		 * 
		 * @return void
		 */
		public function PeriodicExecuter(period:Number, callback:Function, start:Boolean = true) {
			super(period);
			this.period = period;
			this.callback = callback;
			addEventListener(TimerEvent.TIMER, onTick)
			if (start)
				this.start();
		}
		
		/** 
		 * Call the given method on timer event.
		 * 
		 * @param e Timer event.
		 * 
		 * @return void
		 */
		protected function onTick(e:TimerEvent):void {
			callback(e);
		}
	}
}