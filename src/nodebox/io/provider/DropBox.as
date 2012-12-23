package nodebox.io.provider {
	import flash.events.Event;
	import flash.net.*;
	import flash.utils.ByteArray;
	import m.app.AppEvent;
	import m.io.queue.FunctionQueue;
	import nodebox.App;
	import nodebox.app.Config;
	import nodebox.io.Item;
	import nodebox.ui.components.WebBrowser;
	import org.flaircode.oauth.*;
	import org.hamster.dropbox.*;
	import org.hamster.dropbox.models.*;
	import org.iotashan.oauth.*;
	import spark.components.Label;
	
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class DropBox extends AbstractProvider {
		private var dropAPI:DropboxClient;
		private var config:DropboxConfig;	
		private var queue:FunctionQueue = new FunctionQueue();
		
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
		
		override public function getName():String {
			return 'Dropbox';
		}
		
		override public function getLoginformFields():Array {
			var l:Label = new Label();
			l.text = 'Dropbox';//TODo image
			return [];
		}
		
		override public function onLogin(e:Event = null):void { 
			getRequestToken();
		}
		
		override public function onLoginSuccess(e:Event):void {
			getAccountInfo(function(a:AccountInfo):void {
				App.instance.logger.info('connected to DropBox as: '+a.displayName);
			});
			super.onLoginSuccess(e);
		}
		
		private function getRequestToken(callback:Function = null):void {
			var handler:Function = function (e:DropboxEvent):void {
				dropAPI.removeEventListener(DropboxEvent.REQUEST_TOKEN_RESULT, handler);
				
				var browser:WebBrowser = new WebBrowser();
				browser.minimizeButton.visible = false;
				browser.resizeButton.visible = false;
				browser.show(App.instance.window, false, true);
				browser.hideControlls = true;
				browser.load( new URLRequest(dropAPI.authorizationUrl));
				browser.addOnClose(function(e:Event):void {
					getAccessToken(function(e:Event):void {
						if(callback != null)
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
			var handler:Function = function (e:DropboxEvent):void {
				dropAPI.removeEventListener(DropboxEvent.ACCESS_TOKEN_RESULT, handler);
				if (callback != null)
					callback(e);
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
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.ACCESS_TOKEN_RESULT, handler);
				accountInfo = AccountInfo(e.resultObject);
				callback(accountInfo);
			};
			dropAPI.addEventListener(DropboxEvent.ACCOUNT_INFO_RESULT, handler);
			dropAPI.accountInfo();
		}

		override public function uploadFile(path:String, name:String, data:ByteArray, callback:Function = null):void {
			//queue.enqueue(function():void {
				var handler:Function = function (e:DropboxEvent):void{
					dropAPI.removeEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
					if (callback != null) callback(e);
					//queue.queueCallback(callback, e);
					
				};
				dropAPI.addEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
				dropAPI.putFile(path, name, data);
				
			//});
		}
		
		override public function createFolder(path:String, callback:Function = null):void{
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
				if (callback != null)
					callback(generateItemFromFile(e.resultObject as DropboxFile));
			};
			dropAPI.addEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
			dropAPI.fileCreateFolder(path);
		}
		
		override public function deleteFile(file:String, callback:Function = null):void{
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
				if (callback != null)
					callback(e);
			};
			dropAPI.addEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
			dropAPI.fileDelete(file);
		}
		
		override public function getFile(file:String, callback:Function, revision:String = ""):void {
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.GET_FILE_RESULT, handler);
				callback(ByteArray(e.resultObject));
			};
			dropAPI.addEventListener(DropboxEvent.GET_FILE_RESULT, handler);
			dropAPI.getFile(file, revision);
		}
		
		override public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void {
				var handler:Function = function (e:DropboxEvent):void{
					dropAPI.removeEventListener(DropboxEvent.METADATA_RESULT, handler);
					callback(generateItemFromFile(e.resultObject  as DropboxFile));
				};
				dropAPI.addEventListener(DropboxEvent.METADATA_RESULT, handler);
				dropAPI.metadata(path, limit, "", recursive);
		}
		
		override public function isAvailable(path:String, callback:Function):void {
			queue.enqueue(function():void { 
				var faultMethod:Function = function(e:Event):void { 
					queue.queueCallback(callback, false);
				};
				dropAPI.addEventListener(DropboxEvent.METADATA_FAULT, faultMethod);
				getMetadata(path, function(item:Item):void {
					dropAPI.removeEventListener(DropboxEvent.METADATA_FAULT, faultMethod);
					App.instance.logger.info('exists response for: '+item.path+' exists:'+(!item.isDeleted));
					queue.queueCallback(callback, !item.isDeleted);
				});
			} );
		}
		
		override public function getChanged(path:String, callback:Function, cursorRevision:String = null):void {
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.DELTA_RESULT, handler);
				var delta:Delta = e.resultObject as Delta;
				callback(generateItemsFromFiles(delta.entries), delta.cursor);
			};
			dropAPI.addEventListener(DropboxEvent.DELTA_RESULT, handler);
            dropAPI.delta(cursorRevision);
		}
		
		private function generateItemFromFile(input:DropboxFile):Item {
			var output:Item = new Item();
			output.state = Item.ITEM_STATE_INITIALIZED;	
			output.bytes = input.bytes;
			output.modified = input.modified;
			output.isDir = input.isDir;
			output.isDeleted = input.isDeleted;
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
			return output;
		}
		
		private function generateItemsFromFiles(input:Array):Array {
			var output:Array = [];
			for each (var subFile:DropboxFile in input)
				output.push(generateItemFromFile(subFile));
			
			return output;
		}
		
		private function faultHandler(e:Event):void {
			App.instance.logger.error((e as Object).resultObject.toString());
		}
	}
}