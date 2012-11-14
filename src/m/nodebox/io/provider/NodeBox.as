package m.nodebox.io.provider {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class NodeBox extends AbstractProvider {
		
		override public function getName():String {
			return 'nodeBOX';
		}
		
		public function NodeBox() {
			/*package m.nodebox.io.provider {
	import flash.events.Event;
	import flash.net.*;
	import flash.utils.ByteArray;
	import m.app.AppEvent;
	import m.nodebox.App;
	import m.nodebox.app.Config;
	import m.nodebox.io.IOEvent;
	import m.nodebox.io.Item;
	import m.nodebox.ui.components.WebBrowser;
	import mx.core.Window;
	import mx.events.CloseEvent;
	import org.flaircode.oauth.*;
	import org.hamster.dropbox.*;
	import org.hamster.dropbox.models.*;
	import org.iotashan.oauth.*;

	public class DropBox extends AbstractProvider {
		private var dropAPI:DropboxClient;
		private var config:DropboxConfig;		
		public function DropBox() {
			config = new DropboxConfig(Config.get().dataProviders.dropbox.appKey, 
									   Config.get().dataProviders.dropbox.appSecret);
				
			dropAPI = new DropboxClient(config);
			dropAPI.addEventListener(DropboxEvent.ACCESS_TOKEN_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.ACCOUNT_CREATE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.ACCOUNT_INFO_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.COPY_REF_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.DELTA_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.FILE_COPY_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.FILE_CREATE_FOLDER_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.FILE_DELETE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.FILE_MOVE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.GET_FILE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.MEDIA_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.METADATA_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.PUT_FILE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.REQUEST_TOKEN_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.REVISION_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.RESTORE_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.SEARCH_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.SHARES_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.THUMBNAILS_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.TOKEN_FAULT, faultHandler);
		   
			dropAPI.addEventListener(DropboxEvent.CHUNKED_UPLOAD_FAULT, faultHandler);
			dropAPI.addEventListener(DropboxEvent.COMMIT_CHUNKED_UPLOAD_FAULT, faultHandler);
		}

		override public function emailLogin(e:AppEvent):void { 
			var email:String = e.data.name; 
			var password:String = e.data.password;
			getRequestToken(function():void {
				var handler:Function = function (evt:DropboxEvent):void{
					dropAPI.removeEventListener(DropboxEvent.TOKEN_RESULT, handler);
				};
				dropAPI.addEventListener(DropboxEvent.TOKEN_RESULT, handler);
				dropAPI.token(email, password);
			});
		}
		
		override public function onLoginSuccess(e:Event):void {
			super.onLoginSuccess(e);
			getAccountInfo(function(a:AccountInfo):void {
				App.instance.logger.info('connected to DropBox as: '+a.displayName);
			});
		}
		
		private function getRequestToken(callback:Function):void {
			App.instance.logger.info('request token');
			var handler:Function = function (evt:DropboxEvent):void {
				App.instance.logger.info('request token recived, now navigating to: '+dropAPI.authorizationUrl);
				dropAPI.removeEventListener(DropboxEvent.REQUEST_TOKEN_RESULT, handler);
				
				var browser:WebBrowser = new WebBrowser();
				
				browser.show(App.instance.window, false, true);
				browser.hideControlls = true;
				browser.load( new URLRequest(dropAPI.authorizationUrl));
				browser.addOnClose(function(e:Event):void {
					getAccessToken(function(e:Event):void {
						callback(e);
						onLoginSuccess(e);
					});
				});
				browser.width = App.instance.window.width;
				browser.height = App.instance.window.height;
			};
			dropAPI.addEventListener(DropboxEvent.REQUEST_TOKEN_RESULT, handler);
			dropAPI.requestToken();
		}
		
		private function getAccessToken(callback:Function = null):void {
			App.instance.logger.info('request for access token');
			var handler:Function = function (evt:DropboxEvent):void {
				App.instance.logger.info('access token recived');
				dropAPI.removeEventListener(DropboxEvent.ACCESS_TOKEN_RESULT, handler);
				if (callback != null)
					callback(evt);
			};
			dropAPI.addEventListener(DropboxEvent.ACCESS_TOKEN_RESULT, handler);
			dropAPI.accessToken();
		}
		
		private var accountInfo:AccountInfo;
		override public function getAccountInfo(callback:Function):void {
			if (accountInfo != null) {
				callback(accountInfo);
				return ;
			}
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.ACCESS_TOKEN_RESULT, handler);
				accountInfo = AccountInfo(evt.resultObject);
				callback(accountInfo);
			};
			dropAPI.addEventListener(DropboxEvent.ACCOUNT_INFO_RESULT, handler);
			dropAPI.accountInfo();
		}

		override public function uploadFile(path:String, fileReference:FileReference, callback:Function = null):void{
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
				if (callback != null)
					callback(evt);
			};
			dropAPI.addEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
			dropAPI.putFile(path, fileReference.name, fileReference.data);
		}
		
		override public function createFolder(path:String, callback:Function = null):void{
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
				if (callback != null)
					callback(generateItemFromResponse(evt.resultObject));
			};
			dropAPI.addEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
			dropAPI.fileCreateFolder(path);
		}
		
		override public function deleteFile(file:String, callback:Function = null):void{
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
				if (callback != null)
					callback(evt);
			};
			dropAPI.addEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
			dropAPI.fileDelete(file);
		}
		
		override public function getFile(file:String, callback:Function, revision:String=""):void{
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.GET_FILE_RESULT, handler);
				callback(ByteArray(evt.resultObject));
			};
			dropAPI.addEventListener(DropboxEvent.GET_FILE_RESULT, handler);
			dropAPI.getFile(file, revision);
		}
		
		override public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void{
			var handler:Function = function (evt:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.METADATA_RESULT, handler);
				
				callback(generateItemFromResponse(evt.resultObject));
			};
			dropAPI.addEventListener(DropboxEvent.METADATA_RESULT, handler);
			dropAPI.metadata(path, limit, "", recursive);
		}
		
		override public function isAvailable(path:String, callback:Function):void {
			var faultMethod:Function = function(e:Event):void { 
				callback(false);
			};
			
			dropAPI.addEventListener(DropboxEvent.METADATA_FAULT, faultMethod);
			getMetadata(path, function(item:Item):void {
				dropAPI.removeEventListener(DropboxEvent.METADATA_FAULT, faultMethod);
				callback(true);
			});
		}
		
		private function generateItemFromResponse(response:Object):Item {
			var file:DropboxFile = new DropboxFile();
			file.decode(response);
			return generateItemFromFile(file);
		}
		
		private function generateItemFromFile(input:DropboxFile):Item {
			var output:Item = new Item();
			
			output.bytes = input.bytes;
			output.modified = input.modified;
			output.isDir = input.isDir;
			output.root = input.root;
			output.mimeType = input.mimeType;
			output.size = input.size;
			output.path = input.path;
			output.revision = input.revision;
			output.hash = input.hash;
			
			output.childs = {};
			for each (var subFile:DropboxFile in input.contents){
				var item:Item = generateItemFromFile(subFile);
				output.childs[item.path] = item;
			}
			
			output.state = Item.ITEM_STATE_INITIALIZED;	
			output.remoteModel = this;
			return output;
		}
		
		private function faultHandler(evt:Event):void {
			//TODO throw exception
			App.instance.logger.error((evt as Object).resultObject.toString());
		}
		
	}
}*/
		}	
	}
}