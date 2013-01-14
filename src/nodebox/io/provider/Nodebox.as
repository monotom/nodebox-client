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
	import nodebox.io.provider.nodebox.NodeboxEvent;
	import nodebox.io.provider.nodebox.NodeboxModel;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.TextInput;
	
	
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Nodebox implements ProviderInterface {
		private var queue:FunctionQueue = new FunctionQueue();
		/** 
		 * This method 
		 */
		public function getName():String {
			return 'Nodebox';
		}
		
		private var model:NodeboxModel;
		/** 
		 * This method 
		 */
		public function Nodebox() {
			model = new NodeboxModel();
			
			model.addEventListener(NodeboxEvent.LOGIN_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.ACCOUNT_INFO_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.DELTA_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.FILE_COPY_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.FILE_CREATE_FOLDER_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.FILE_DELETE_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.FILE_MOVE_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.GET_FILE_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.PUT_FILE_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.SEARCH_FAULT, faultHandler);
		}
			
		private var iServer:TextInput = new TextInput();
		private var iUser:TextInput = new TextInput();
		private var iPass:TextInput = new TextInput();
		/** 
		 * Get the elements that collects the data needed for the login process
		 * 
		 * @return An array containing IVisualElements or an second array containing IVisualElements that will be displayed in a row.
		 */
		public function getLoginformFields():Array {
			var l:Label = new Label(), lServer:Label = new Label(), 
			lUser:Label = new Label(), lPass:Label = new Label();
			
			l.text = 'Nodebox';
			
			lServer.text = 'nodebox server';
			lServer.width = 90;
			iServer.text = AppConfig.xml.dataProviders.nodebox.server + ':' + AppConfig.xml.dataProviders.nodebox.port;
			
			lUser.text = 'user name';
			lUser.width = 90;
			iUser.text = 'testuser';
			
			lPass.text = 'pwd';
			lPass.width = 90;
			iPass.displayAsPassword = true;
			iPass.text = 'pwd';
			
			return [[lServer, iServer],	[lUser, iUser],	[lPass, iPass]];
		}
		
		/** 
		 * This method is called when the connect button of the login form is pressed.
		 * 
		 * @param e The event that triggered the call of that method.
		 */
		public function onLogin(e:Event = null):void {
			accountInfo = null;
			var handler:Function = function(e:NodeboxEvent):void {
				model.removeEventListener(NodeboxEvent.LOGIN_RESULT, handler);
				onLoginSuccess(e);
			}
			model.addEventListener(NodeboxEvent.LOGIN_RESULT, handler)
			model.login(iServer.text, iUser.text, iPass.text);
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECT));
		}
		
		[Embed(source="../../../../bin/assets/img/provider/nodebox.png")]
		private static var Logo:Class;		
		/**
		 * This image will be displayed next to the login form and on the desktop background.
		 * 
		 * @return A image with the provider logo.
		 */
		public function getImage():Image {
			var img:Image = new Image();
			img.source = new Logo();
			return img;
		}
		
		/** 
		 * This string will be displayed next to the login form.
		 * 
		 * @return Information about the login process.
		 */
		public function getInfo():String {
			return "Just connect to your private Nodebox-Server Instance.";
		}
		
		/** 
		 * This method gives a unique string for storing the users data in the local file system.
		 * So many users can store their data with the same client.
		 * 
		 * @return A unique string corresponding to the logged in account.
		 */
		public function uniqueUserId():String {
			return MD5.hash(iServer.text + iUser.text);
		}
		
		/** 
		 * This method 
		 */
		public function getSupportedEvents():Array {
			return [];
		}
		
		/** 
		 * This method 
		 */
		public function onLoginSuccess(e:Event):void {
			getAccountInfo(function(a:Object):void {
				App.instance.logger.info('connected to Nodebox as: ' + a.displayName);
			});
			App.instance.dispatchEvent(new AppEvent(AppEvent.ON_APP_CONNECTED));
			App.instance.logger.info('connected to Nodebox ');
		}
			
		private var accountInfo:Object;
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
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.ACCOUNT_INFO_RESULT, handler);
				accountInfo = e.resultObject;
				callback(accountInfo);
			};
			model.addEventListener(NodeboxEvent.ACCOUNT_INFO_RESULT, handler);
			model.accountInfo();
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
				var handler:Function = function (e:NodeboxEvent):void{
					model.removeEventListener(NodeboxEvent.PUT_FILE_RESULT, handler);
					uploadQueue.queueCallback(callback, e);					
				};
				model.addEventListener(NodeboxEvent.PUT_FILE_RESULT, handler);
				model.putFile(path, name, data);
			});
		}
		
		/** 
		 * This method creates a folder recursive remote.
		 * 
		 * @param path Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		public function createFolder(path:String, callback:Function = null):void{
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
				if (callback != null)
					callback(generateItemFromFile(e.resultObject));
			};
			model.addEventListener(NodeboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
			model.createFolder(path);
		}
		
		/** 
		 * This method deletes a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 */
		public function deleteFile(file:String, callback:Function = null):void{
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.FILE_DELETE_RESULT, handler);
				if (callback != null)
					callback(e);
			};
			model.addEventListener(NodeboxEvent.FILE_DELETE_RESULT, handler);
			model.deleteFile(file);
		}
		
		/** 
		 * This method gets the content of a remote file.
		 * 
		 * @param file Relative path to the file within the users desktop.
		 * @param callback A method that is called when the informations are available.
		 * @param revision The revision of the file that content should retrieved.
		 */
		public function getFile(file:String, callback:Function, revision:String = ""):void {
			var handler:Function = function (e:NodeboxEvent):void{
			    model.removeEventListener(NodeboxEvent.GET_FILE_RESULT, handler);
				queue.queueCallback(callback, ByteArray(e.resultObject));
			};
			queue.enqueue(function():void {
				model.addEventListener(NodeboxEvent.GET_FILE_RESULT, handler);
				model.getFile(file, revision);
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
					model.removeEventListener(NodeboxEvent.METADATA_FAULT, faultMethod);
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
			var handler:Function = function (e:NodeboxEvent):void {
				model.removeEventListener(NodeboxEvent.METADATA_RESULT, handler);
				model.removeEventListener(NodeboxEvent.METADATA_FAULT, faultHandler);
				if (e.resultObject.hasOwnProperty('error'))
					faultHandler(e);
				else
					queue.queueCallback(callback, generateItemFromFile(e.resultObject));
			};
			var faultHandler:Function = function(e:NodeboxEvent):void {
				model.removeEventListener(NodeboxEvent.METADATA_RESULT, handler);
				model.removeEventListener(NodeboxEvent.METADATA_FAULT, faultHandler);
				var item:Item = new Item();
				item.path = path;
				item.isDeleted = true;
				queue.queueCallback(callback, item);
			}
			queue.enqueue(function():void {
				model.addEventListener(NodeboxEvent.METADATA_RESULT, handler);
				model.addEventListener(NodeboxEvent.METADATA_FAULT, faultHandler);
				model.getMetadata(path, limit, recursive);
			});
		}
		
		/** 
		 * This method converts the json response object to a nodebox.io.Item object
		 */
		private function generateItemFromFile(input:Object):Item {
			var output:Item = new Item();
			
			output.bytes = input['bytes'];
			output.modified = new Date(input['modified']);
			output.isDir = String(input['is_dir']) == 'true';
			output.root = input['root'];
			output.size = input['size'];
			output.path = input['path'];
			output.revision = input['revision'];
			output.isDeleted = input['is_deleted'];
			output.hash = input['hash'];
			output.childs = new Object();
			for each (var content:Object in input['childs']) {
				var item:Item = generateItemFromFile(content)
				output.childs[item.path] = item;
			}
			return output;
		}
		
		/** 
		 * This method converts the json response objects to nodebox.io.Item objects
		 */
		private function generateItemsFromFiles(input:Array):Array {
			var output:Array = [];
			for each (var subFile:Object in input)
				output.push(generateItemFromFile(subFile));
			
			return output;
		}
		
		/** 
		 * This method loggs the errors
		 */
		private function faultHandler(e:Event):void {
			App.instance.logger.error(e.type+' '+(e as Object).resultObject.toString());
		}
	}
}