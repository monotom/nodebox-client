package m.app 
{
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import mx.logging.*;
	import mx.logging.targets.LineFormattedTarget;

	public class Logger{
		static private var logger:ILogger = Log.getLogger("sample.MyApp");
    
		public var logLevel:int;
		public function Logger(level:int = 31) {
			this.logLevel = level;
			
			var target:LineFormattedTarget = new LineFormattedTarget();
			target.filters = ["*"];
			target.includeDate = true;
			target.includeTime = true;
			target.includeCategory = true;
			target.includeLevel = true;
			Log.addTarget(target);
		}
		
		private var callback:Function = null;
		public function setCallBack(callback:Function):void {
			this.callback = callback;
		}
		
		public function info(msg:String):void { //8
			if(logLevel & 8)      logger.info('INFO: ' + msg);
			if (logLevel & 2)     trace('INFO: ' + msg);	
			if (callback != null) callback('INFO: ' + msg);
		}
		
		public function warning(msg:String):void { //4
			if(logLevel & 4)      logger.warn('WARNING: ' + msg);
			if (logLevel & 2)     trace('WARNING: ' + msg);	
			if (callback != null) callback('WARNING: ' + msg);
		}
		
		public function debug(msg:String):void {//16
			if(logLevel & 16) 	  logger.debug('DEBUG: ' + msg);
			if (logLevel & 2)	  trace('DEBUG: ' + msg);	
			if (callback != null) callback('DEBUG: ' + msg);
		}
		
		public function error(msg:String):void { //1
			if(logLevel & 1)	  logger.error('ERROR: ' + msg);
			if (logLevel & 2)	  trace('ERROR: ' + msg);	
			if (callback != null) callback('ERROR: ' + msg);
		}
	}
}