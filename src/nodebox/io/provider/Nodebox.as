package nodebox.io.provider {
	import flash.events.Event;
	import flash.net.*;
	import flash.utils.ByteArray;
	import m.io.queue.FunctionQueue;
	import nodebox.App;
	import nodebox.io.Item;
	import nodebox.io.provider.nodebox.NodeboxModel;
	import nodebox.io.provider.nodebox.NodeboxEvent;
	import org.hamster.dropbox.models.AccountInfo;
	import spark.components.Label;
	import spark.components.TextInput;
	import nodebox.app.Config;
	
	
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Nodebox extends AbstractProvider {
		private var queue:FunctionQueue = new FunctionQueue();
		override public function getName():String {
			return 'Nodebox';
		}
		
		private var model:NodeboxModel;
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
			model.addEventListener(NodeboxEvent.METADATA_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.PUT_FILE_FAULT, faultHandler);
			model.addEventListener(NodeboxEvent.SEARCH_FAULT, faultHandler);
			
			model.addEventListener(NodeboxEvent.ACCOUNT_INFO_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.PUT_FILE_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.FILE_COPY_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.FILE_CREATE_FOLDER_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.FILE_DELETE_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.FILE_MOVE_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.GET_FILE_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.METADATA_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.DELTA_RESULT, resultHandler);
			model.addEventListener(NodeboxEvent.LOGIN_RESULT, onLoginSuccess);
		}
		
		private function resultHandler(e:NodeboxEvent):void {
			
		}
		
		private var iServer:TextInput = new TextInput();
		private var iUser:TextInput = new TextInput();
		private var iPass:TextInput = new TextInput();
		override public function getLoginformFields():Array {
			var l:Label = new Label()
			l.text = 'Nodebox';
			
			var lServer:Label = new Label();
			lServer.text = 'Nodebox Server IP';
			iServer.text = Config.get().dataProviders.nodebox.server + ':' + Config.get().dataProviders.nodebox.port;//'192.168.11.2:8881';// 
			
			var lUser:Label = new Label();
			lUser.text = 'Benutzername';
			iUser.text = 'mono';
			
			var lPass:Label = new Label();
			lPass.text = 'Passwort';
			iPass.displayAsPassword = true;
			iPass.text = 'pwd';
			
			return [ //l, TODO image
					[lServer, iServer],
					[lUser, iUser],
					[lPass, iPass]];
		}
		
		override public function onLogin(e:Event = null):void {
			var handler:Function = function(e:NodeboxEvent):void {
				model.removeEventListener(NodeboxEvent.ACCOUNT_INFO_RESULT, handler);
				onLoginSuccess(e);
			}
			model.addEventListener(NodeboxEvent.ACCOUNT_INFO_RESULT, handler)
			model.login(iServer.text, iUser.text, iPass.text);
		}
		
		override public function onLoginSuccess(e:Event):void {
			getAccountInfo(function(a:Object):void {
				App.instance.logger.info('connected to Nodebox as: '+a.displayName);
			});
			App.instance.logger.info('connected to Nodebox ');
			super.onLoginSuccess(e);
		}
			
		private var accountInfo:Object;
		override public function getAccountInfo(callback:Function):void {
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

		override public function uploadFile(path:String, name:String, data:ByteArray, callback:Function = null):void {
			//queue.enqueue(function():void {
				var handler:Function = function (e:NodeboxEvent):void{
					model.removeEventListener(NodeboxEvent.PUT_FILE_RESULT, handler);
					if (callback != null) callback(e);
					//queue.queueCallback(callback, e);
				};
				model.addEventListener(NodeboxEvent.PUT_FILE_RESULT, handler);
				model.putFile(path, name, data);
			//});
		}
		
		override public function createFolder(path:String, callback:Function = null):void{
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
				if (callback != null)
					callback(generateItemFromFile(e.resultObject));
			};
			model.addEventListener(NodeboxEvent.FILE_CREATE_FOLDER_RESULT, handler);
			model.createFolder(path);
		}
		
		override public function deleteFile(file:String, callback:Function = null):void{
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.FILE_DELETE_RESULT, handler);
				if (callback != null)
					callback(e);
			};
			model.addEventListener(NodeboxEvent.FILE_DELETE_RESULT, handler);
			model.deleteFile(file);
		}
		
		override public function getFile(file:String, callback:Function, revision:String = ""):void {
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.GET_FILE_RESULT, handler);
				callback(ByteArray(e.resultObject));
			};
			model.addEventListener(NodeboxEvent.GET_FILE_RESULT, handler);
			model.getFile(file, revision);
		}
		
		override public function getMetadata(path:String, callback:Function, limit:int = 1000, recursive:Boolean = true):void {
				var handler:Function = function (e:NodeboxEvent):void{
					model.removeEventListener(NodeboxEvent.METADATA_RESULT, handler);
					callback(generateItemFromFile(e.resultObject));
				};
				model.addEventListener(NodeboxEvent.METADATA_RESULT, handler);
				model.getMetadata(path, limit, recursive);
		}
		
		override public function isAvailable(path:String, callback:Function):void {
			queue.enqueue(function():void { 
				var faultMethod:Function = function(e:Event):void { 
					queue.queueCallback(callback, false);
				};
				model.addEventListener(NodeboxEvent.METADATA_FAULT, faultMethod);
				getMetadata(path, function(item:Item):void {
					model.removeEventListener(NodeboxEvent.METADATA_FAULT, faultMethod);
					App.instance.logger.info('exists response for: '+item.path+' exists:'+(!item.isDeleted));
					queue.queueCallback(callback, !item.isDeleted);
				});
			} );
		}
		
		override public function getChanged(path:String, callback:Function, cursorRevision:String = null):void {
			var handler:Function = function (e:NodeboxEvent):void{
				model.removeEventListener(NodeboxEvent.DELTA_RESULT, handler);
				//var delta:Delta = e.resultObject as Delta;
				//callback(generateItemsFromFiles(delta.entries), delta.cursor);
			};
			model.addEventListener(NodeboxEvent.DELTA_RESULT, handler);
            model.delta(cursorRevision);
		}
		
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
		
		private function generateItemsFromFiles(input:Array):Array {
			var output:Array = [];
			for each (var subFile:Object in input)
				output.push(generateItemFromFile(subFile));
			
			return output;
		}
		
		private function faultHandler(e:Event):void {
			App.instance.logger.error(e.type);
			//App.instance.logger.error((e as NodeboxEvent).resultObject.toString());
		}
	}
}