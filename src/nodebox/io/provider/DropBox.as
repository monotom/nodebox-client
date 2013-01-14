package nodebox.io.provider {
	import com.adobe.crypto.MD5;
	import flash.events.Event;
	import flash.net.*;
	import flash.utils.ByteArray;
	import m.app.AppConfig;
	import m.app.AppEvent;
	import m.io.queue.FunctionQueue;
	import nodebox.App;
	import nodebox.io.Item;
	import nodebox.ui.components.WebBrowser;
	import org.flaircode.oauth.*;
	import org.hamster.dropbox.*;
	import org.hamster.dropbox.models.*;
	import org.iotashan.oauth.*;
	import spark.components.Image;
	import spark.components.Label;
	
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class DropBox implements ProviderInterface {
		private var dropAPI:DropboxClient;
		private var config:DropboxConfig;	
		private var queue:FunctionQueue = new FunctionQueue();
		
		/** 
		 * This method 
		 */
		public function DropBox() {
			config = new DropboxConfig(AppConfig.xml.dataProviders.dropbox.appKey, 
									   AppConfig.xml.dataProviders.dropbox.appSecret);
				
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
		
		/**
		 * This image will be displayed next to the login form and on the desktop background.
		 * 
		 * @return A image with the provider logo.
		 */
		public function getName():String {
			return 'Dropbox';
		}
		
		/** 
		 * This string will be displayed next to the login form.
		 * 
		 * @return Information about the login process.
		 */
		public function getInfo():String {
			return "If you press \"connect\" a browser will open showing the Dropbox website. You have to enter your account data and give permissions to the Nodebox-Client. If this was successfull, simply close the window and the Nodebox-Client will do the rest.";
		}
		
		/** 
		 * Get the elements that collects the data needed for the login process
		 * 
		 * @return An array containing IVisualElements or an second array containing IVisualElements that will be displayed in a row.
		 */
		public function getLoginformFields():Array {
			var l:Label = new Label();
			l.text = 'Dropbox';
			return [];
		}
		
		[Embed(source="../../../../bin/assets/img/provider/dropbox.png")]
		private static var Logo:Class;		
		/** 
		 * This method returns the provider logo
		 */
		public function getImage():Image {
			var img:Image = new Image();
			img.source = new Logo();
			return img;
		}
		
		/** 
		 * Interface implementation nodebox.plugins.PluginInterface
		 */
		public function getSupportedEvents():Array {
			return [];
		}
		
		/** 
		 * This method is called when the connect button of the login form is pressed.
		 * 
		 * @param e The event that triggered the call of that method.
		 */
		public function onLogin(e:Event = null):void { 
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT));
			accountInfo = null;
			getRequestToken();
		}
		
		/** 
		 * This method starts the authentication process and open a webbrowser window
		 */
		private function getRequestToken(callback:Function = null):void {
			var handler:Function = function (e:DropboxEvent):void {
				dropAPI.removeEventListener(DropboxEvent.REQUEST_TOKEN_RESULT, handler);
				
				var browser:WebBrowser = new WebBrowser();
				browser.minimizeButton.visible = false;
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
				browser.height = App.instance.window.height - 40;
			};
			dropAPI.addEventListener(DropboxEvent.REQUEST_TOKEN_RESULT, handler);
			dropAPI.requestToken();
		}
		
		private var uid:String = ''; 
		/** 
		 * This method gives a unique string for storing the users data in the local file system.
		 * So many users can store their data with the same client.
		 * 
		 * @return A unique string corresponding to the logged in account.
		 */
		public function uniqueUserId():String {
			return uid;
		}
		
		/** 
		 * This method 
		 */
		public function onLoginSuccess(e:Event):void {
			getAccountInfo(function(a:AccountInfo):void {
				uid = MD5.hash(''+a.uid);
				App.instance.logger.info('connected to DropBox as: ' + a.displayName);
				App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECTED));
			});
		}
		
		/** 
		 * This method 
		 */
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
		/** 
		 * This method gets information about the logged in user from the data provider. 
		 * 
		 * @param callback A method that is called when the informations are available.
		 */
		public function getAccountInfo(callback:Function):void {
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

		/** 
		 * This method uploads a new or changed file to the file hoster.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param name The name of the file.
		 * @param data The content of the file in form of a byte array.
		 * @param callback A method that is called when the informations are available.
		 */
		private var uploadQueue:FunctionQueue = new FunctionQueue();
		public function uploadFile(path:String, name:String, data:ByteArray, callback:Function = null):void {
			uploadQueue.enqueue(function():void {
				var handler:Function = function (e:DropboxEvent):void{
					dropAPI.removeEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
					uploadQueue.queueCallback(callback, e);					
				};
				dropAPI.addEventListener(DropboxEvent.PUT_FILE_RESULT, handler);
				dropAPI.putFile(path, name, data);
			});
		}
		
		/** 
		 * This method creates a folder recursive remote.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		public function createFolder(path:String, callback:Function = null):void{
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
				if (callback != null)
					callback(generateItemFromFile(e.resultObject as DropboxFile));
			};
			dropAPI.addEventListener(DropboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
			dropAPI.fileCreateFolder(path);
		}
		
		/** 
		 * This method deletes a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		public function deleteFile(file:String, callback:Function = null):void{
			var handler:Function = function (e:DropboxEvent):void{
				dropAPI.removeEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
				if (callback != null)
					callback(e);
			};
			dropAPI.addEventListener(DropboxEvent.FILE_DELETE_RESULT, handler);
			dropAPI.fileDelete(file);
		}
		
		/** 
		 * This method gets the content of a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 * @param revision The revision of the file that content should retrieved.
		 */
		public function getFile(file:String, callback:Function, revision:String = ""):void {
			var handler:Function = function (e:DropboxEvent):void{
			    dropAPI.removeEventListener(DropboxEvent.GET_FILE_RESULT, handler);
				queue.queueCallback(callback, ByteArray(e.resultObject));
			};
			queue.enqueue(function():void {
				dropAPI.addEventListener(DropboxEvent.GET_FILE_RESULT, handler);
				dropAPI.getFile(file, revision);
			});
		}
		
		/** 
		 * This method tests if a file exists on the provider side.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		private var existsQueue:FunctionQueue = new FunctionQueue();
		public function isAvailable(path:String, callback:Function):void {
			existsQueue.enqueue(function():void { 
				var faultMethod:Function = function(e:Event):void { 
					existsQueue.queueCallback(callback, false);
				};
				getMetadata(path, function(item:Item):void {
					dropAPI.removeEventListener(DropboxEvent.METADATA_FAULT, faultMethod);
					existsQueue.queueCallback(callback, !item.isDeleted);
				});
			} );
		}
	
		/** 
		 * This method gets the metadata of a file and should produce a nodebox.io.Item. @see nodebox.io.Item.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 * @param limit If supported limits the count of files.
		 * @param recursive If supported and the path points to a directory process the directory recursive.
		 */
		public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void {
			var handler:Function = function (e:DropboxEvent):void {
				dropAPI.removeEventListener(DropboxEvent.METADATA_RESULT, handler);
				dropAPI.removeEventListener(DropboxEvent.METADATA_FAULT, faultHandler);
				queue.queueCallback(callback, generateItemFromFile(e.resultObject  as DropboxFile));
			};
			var faultHandler:Function = function(e:DropboxEvent):void {
				dropAPI.removeEventListener(DropboxEvent.METADATA_RESULT, handler);
				dropAPI.removeEventListener(DropboxEvent.METADATA_FAULT, faultHandler);
				var item:Item = new Item();
				item.path = path;
				item.isDeleted = true;
				queue.queueCallback(callback, item);
			}
			queue.enqueue(function():void {
				dropAPI.addEventListener(DropboxEvent.METADATA_RESULT, handler);
				dropAPI.addEventListener(DropboxEvent.METADATA_FAULT, faultHandler);
				dropAPI.metadata(path, limit, "", recursive);
			});
		}
		
		/** 
		 * This method converts DropboxFile object to a nodebox.io.Item object
		 */
		private function generateItemFromFile(input:DropboxFile):Item {
			var output:Item = new Item();
			output.bytes = input.bytes;
			output.modified = input.modified;
			output.isDir = input.isDir;
			output.isDeleted = input.isDeleted;
			output.root = input.root;
			output.mimeType = input.mimeType;
			output.size = input.size;
			output.path = input.path;
			output.revision = input.hasOwnProperty('rev') ? input.rev : input.revision;
			output.hash = input.hash;
			output.childs = {};
			for each (var subFile:DropboxFile in input.contents){
				var item:Item = generateItemFromFile(subFile);
				output.childs[item.path] = item;
			}
			return output;
		}
		
		/** 
		 * This method converts DropboxFile objects to nodebox.io.Item objects
		 */
		private function generateItemsFromFiles(input:Array):Array {
			var output:Array = [];
			for each (var subFile:DropboxFile in input)
				output.push(generateItemFromFile(subFile));
			
			return output;
		}
		
		/** 
		 * This method loggs the errors
		 */
		private function faultHandler(e:Event):void {
			App.instance.logger.error((e as Object).resultObject.toString());
		}
	}
}