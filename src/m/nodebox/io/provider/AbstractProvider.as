package m.nodebox.io.provider {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.getQualifiedSuperclassName;
	import m.app.AppEvent;
	import m.nodebox.App;
	
	public class AbstractProvider {
		public function AbstractProvider() {
		}
		
		public function getName():String {
			return getQualifiedSuperclassName(this);
		}
		
		public function needsUserAndPass():Boolean {
			return true;
		}
		
		public function getSupportedEvents():Array {
			return [ {name:AppEvent.ON_APP_CONNECT, dispatcher:emailLogin}];
		}
		
		public function emailLogin(e:AppEvent):void { 
		}
		
		public function onLoginSuccess(e:Event):void {
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECTED, e));
		}
		
		public function isAvailable(path:String, callback:Function):void {
			callback(false);
		}
		
		public function getAccountInfo(callback:Function):void {
		}

		public function uploadFile(path:String, fileReference:FileReference, callback:Function = null):void{
		}
		
		public function createFolder(path:String, callback:Function = null):void{
		}

		public function deleteFile(file:String, callback:Function = null):void{
		}

		public function getFile(file:String, callback:Function, revision:String=""):void{
		}

		public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void{
		}
	}
}