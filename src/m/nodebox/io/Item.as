package m.nodebox.io{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import m.nodebox.App;
	import m.nodebox.io.provider.AbstractProvider;
	/**
	 * either a dropbox file or a dropbox folder.
	 * 
	 * @author yinzeshuo
	 */
	public class Item extends EventDispatcher{
		public var bytes:Number;
		public var size:String;
		public var modified:Date;
		public var isDir:Boolean;
		public var root:String;
		public var mimeType:String;
		public var path:String;
		public var revision:String;
		public var isDeleted:Boolean;
		
		public var hash:String;
		public var childs:Object;
		
		public static const ITEM_STATE_UNINITIALIZED:int = 0;
		public static const ITEM_STATE_INITIALIZED:int = 1;
		public static const ITEM_STATE_LOCAL_AVAILABLE:int = 2;
		public static const ITEM_STATE_LOCKED:int = 3;
		
		public var state:int = ITEM_STATE_UNINITIALIZED;
		
		public var remoteModel:AbstractProvider;
		public var localModel:LocalItemModel;
		public function Item() {
			localModel = new LocalItemModel(App.getConfig());
		}
		
		public function get name():String {
			return path.split('/').pop();
		}
		
		public function set name(value:String):void {
			var tmp:Array = path.split('/');
			tmp.pop();
			path = tmp.join('/')+'/'+value;
		}
		
		private var iconPath:String;
		public function get icon():Bitmap {
			return App.instance.assets.getImageFromExtension(extension);
		}
		
		public function get extension():String {
			return (name.indexOf('.') != -1) ? name.split('.').pop() : '';
		}
		
		public function getLocalFile():File {
			return localModel.getFile(path);
		}
		
		public function isLocalAvailable():Boolean {
			return localModel.isAvailable(path);
		}
		
		public function isRemoteAvailable(callback:Function):void {
			return remoteModel.isAvailable(path, callback);
		}
		
		public function makeLokalAvailable(callback:Function):void {
			if(!isLocalAvailable())
				remoteModel.getFile(path, function(data:ByteArray):void {
					localModel.writeBinary(path, data);
					callback(this);
				});
			else
				callback(this);
		}
		
		public function updateRemote(callback:Function = null):void {
			remoteModel.uploadFile(path, localModel.getFileRefference(path), callback);
		}
		
		public function create(callback:Function = null):void {
			if (!isLocalAvailable()){
				createLocal(function(e:Event = null):void {
					isRemoteAvailable(function(exists:Boolean):void {
						if(!exists)
							createRemote(callback);
						else if(callback != null)
							callback(this);
					});
				});
			}
			else {
				isRemoteAvailable(function(exists:Boolean):void {
					if(!exists)
						createRemote(callback);
				});
			}
		}
			
			private function createLocal(callback:Function = null):void {
				localModel.create(path);
				if(callback != null)
					callback();
			}
			
			private function createRemote(callback:Function = null):void {
				if (isDir)
					remoteModel.createFolder(path, callback);
				else if (isLocalAvailable())
					updateRemote(callback);
			}
			
		public function remove(callback:Function = null):void {
			if (isLocalAvailable()) {
				removeLocal(function(e:Event):void {
					isRemoteAvailable(function(exists:Boolean):void {
						if(exists)
							removeRemote(callback);
						else if(callback != null)
							callback(this);
					});
				});
			}
			else {
				isRemoteAvailable(function(exists:Boolean):void {
					if(exists)
						removeRemote(callback);
				});
			}
		}
	
			private function removeLocal(callback:Function = null):void {
				localModel.remove(path);
				if(callback != null)
					callback(this);
			}
			
			private function removeRemote(callback:Function = null):void {
				remoteModel.deleteFile(path, callback);
			}
		
		public function getContentAsBinary(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function():void {
					callback(localModel.getContentAsBinary(path));
				});
			}
			else {
				callback(localModel.getContentAsBinary(path));
			}
		}
		
		public function getContentAsText(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function():void {
					callback(localModel.getContentAsText(path));
				});
			}
			else {
				callback(localModel.getContentAsText(path));
			}
		}
		
		public function getContentAsJson(callback:Function):void {
			if (!isLocalAvailable()) {
				makeLokalAvailable(function():void {
					callback(localModel.getContentAsJson(path));
				});
			}
			else {
				callback(localModel.getContentAsJson(path));
			}
		}
		
		override public function toString():String {
			var s:String = "DropboxFile [bytes=" + bytes
			s	+=  ", hash=" + (hash == null ? "null" : hash) 
			s	+=  ", revision=" + (revision == null ? "null" : revision) 
			s	+=  ", isDir=" + isDir == null
			s	+=  ", mimeType=" + (mimeType == null ? "null" : mimeType)
			s	+=  ", modified=" + (modified == null ? "null" : modified.toString())
			s	+=  ", root=" + (root == null ? "null" : root)
			s	+=  ", path=" + (path == null ? "null" : path)
			s	+=  ", size=" + (size == null ? "null" : size)
			s	+=  ", childs=" + (childs == null || childs.length == 0 ? "null" : childs.join()) + "]";
			return s;
		}
		
		/*	
		public function rename(callback:Function):void {
			
		}
	
			public function renameLocal(callback:Function):void {
				
			}
			
			public function renameRemote(callback:Function):void {
				remoteModel.
			}
		
		public function copy(callback:Function):void {
			
		}
	
			public function copyLocal(callback:Function):void {
				
			}
			
			public function copyRemote(callback:Function):void {
				
			}
		*/
	}
}