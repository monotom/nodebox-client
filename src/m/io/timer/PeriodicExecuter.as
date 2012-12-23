package m.io.timer {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class PeriodicExecuter extends Timer {
		protected var period:Number;
		protected var callback:Function;
		public function PeriodicExecuter(period:Number, callback:Function, start:Boolean = true) {
			super(period);
			this.period = period;
			this.callback = callback;
			addEventListener(TimerEvent.TIMER, onTick)
			if (start)
				this.start();
		}
		
		protected function onTick(e:TimerEvent):void {
			callback(e);
		}
	}
}