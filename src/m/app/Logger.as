package m.app 
{
	/**
	 * This class handles the application logging.
	 * 
	 * @author Tom Hanoldt
	 */
	import mx.logging.*;
	import mx.logging.targets.LineFormattedTarget;

	public class Logger{
		static private var logger:ILogger = Log.getLogger("nodebox");
		
		public static const LOG_LEVEL_ERROR:int = 1;
		public static const TRACE_ALL:int = 2;
		public static const LOG_LEVEL_WARNING:int = 4;
		public static const LOG_LEVEL_INFO:int = 8;
		public static const LOG_LEVEL_DEBUG:int = 16;
		
		public var logLevel:int;
		/** 
		 * Constructor
		 * 
		 * @param level The log level. Bit number 1=error, 2=all, 4=warning, 8=info, 16=debug
		 * 
		 * @return void
		 */
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
		/** 
		 * Set a callback method that is executed on every log line.
		 * 
		 * @param callback The method called when there is a message to log.
		 */
		public function setCallBack(callback:Function):void {
			this.callback = callback;
		}
		
		/** 
		 * Log a info message.
		 * 
		 * @param msg The Message to log.
		 */
		public function info(msg:String):void {
			if (logLevel & LOG_LEVEL_INFO)     logger.info('INFO: ' + msg);
			if (logLevel & TRACE_ALL)     trace('INFO: ' + msg);	
			if (callback != null) callback('INFO: ' + msg);
		}
		
		/** 
		 * Log a warning message.
		 * 
		 * @param msg The Message to log.
		 * 
		 * @return void
		 */
		public function warning(msg:String):void { //4
			if(logLevel & LOG_LEVEL_WARNING)      logger.warn('WARNING: ' + msg);
			if (logLevel & TRACE_ALL)     trace('WARNING: ' + msg);	
			if (callback != null) callback('WARNING: ' + msg);
		}
		
		/** 
		 * Log a debug message.
		 * 
		 * @param msg The Message to log.
		 * 
		 * @return void
		 */
		public function debug(msg:String):void {//16
			if(logLevel & LOG_LEVEL_DEBUG) 	  logger.debug('DEBUG: ' + msg);
			if (logLevel & TRACE_ALL)	  trace('DEBUG: ' + msg);	
			if (callback != null) callback('DEBUG: ' + msg);
		}
		
		/** 
		 * Log a error message.
		 * 
		 * @param msg The Message to log.
		 * 
		 * @return void
		 */
		public function error(msg:String):void { //1
			if(logLevel & LOG_LEVEL_ERROR)	  logger.error('ERROR: ' + msg);
			if (logLevel & TRACE_ALL)	  trace('ERROR: ' + msg);	
			if (callback != null) callback('ERROR: ' + msg);
		}
	}
}