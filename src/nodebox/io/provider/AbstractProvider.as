package nodebox.io.provider {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedSuperclassName;
	import m.app.AppEvent;
	import m.io.queue.FunctionQueue;
	import nodebox.App;
	
	public class AbstractProvider {
		public function AbstractProvider() {
		}
		
		public function getName():String {
			return getQualifiedSuperclassName(this);
		}
		
		public function getLoginformFields():Array {
			return [];
		}
		
		public function getSupportedEvents():Array {
			return [];// [ { name:AppEvent.ON_APP_CONNECT, dispatcher:onLogin } ];
		}
		
		public function onLogin(e:Event = null):void {
		}
		
		public function onLoginSuccess(e:Event):void {
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECTED, e));
		}
		
		public function isAvailable(path:String, callback:Function):void {
			callback(false);
		}
		
		public function getAccountInfo(callback:Function):void {
		}

		public function uploadFile(path:String, name:String, data:ByteArray, callback:Function = null):void{
		}
		
		public function createFolder(path:String, callback:Function = null):void{
		}

		public function deleteFile(file:String, callback:Function = null):void{
		}

		public function getFile(file:String, callback:Function, revision:String=""):void{
		}

		public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void{
		}
		
		public function getChanged(path:String, callback:Function, cursorRevision:String = null):void {
		}
	}
}