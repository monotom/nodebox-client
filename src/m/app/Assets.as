package m.app {
	import flash.events.Event;
	import flash.filesystem.File;
	import mx.core.BitmapAsset;
	import spark.components.Image;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class Assets {
		private var assetsPath:String;
		private var imagePath:String;
		public function Assets(assetsPath:String) {
			this.assetsPath = File.applicationDirectory.resolvePath(assetsPath).nativePath;
			this.imagePath = this.assetsPath+File.separator+'img'+File.separator;
		}
		
		private var imageCache:Object = new Object();
		public function getImage(relativePath:String, callback:Function = null):Image {
			var path:String = getImagePath(relativePath);
			if (imageCache.hasOwnProperty(path))
				return imageCache[path];
				
			imageCache[path] = new Image();        
			if(callback != null)
				imageCache[path].addEventListener(Event.COMPLETE, callback);
            
			imageCache[path].source = File.applicationDirectory.resolvePath(path).url;
			return imageCache[path];
		}
		
		public function getImagePath(relativePath:String):String {
			return File.applicationDirectory.resolvePath(imagePath + relativePath).nativePath;
		}
		
		[Embed(source="../../../bin/assets/img/mime/binary.png")]
		public static var DefaultItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/flash.png")]
		public static var FlashItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/binary.png")]
		public static var BinaryItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/folder.png")]
		public static var FolderItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/pdf.png")]
		public static var PdfItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/sound.png")]
		public static var SoundItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/url.png")]
		public static var UrlItemPicture:Class;		
		
		[Embed(source="../../../bin/assets/img/mime/text.png")]
		public static var TextItemPicture:Class;		
		
		public function getImageFromExtension(extension:String):BitmapAsset {
			if (extension.length < 1)
				return new FolderItemPicture();
				
			switch(extension.toLowerCase()){
				case 'txt':
				case 'rtf':
				case 'doc':
				case 'xml':
				case 'as':
				case 'py':
				case 'c':
				case 'cpp':
				case 'php':
				case 'java':					
					return new TextItemPicture();	
				break;
				case 'pdf':					
					return new PdfItemPicture();	
					break;
				case 'mp3':
				case 'wav':
					return new SoundItemPicture();	
					break;
				case 'flv':
				case 'swc':
					return new FlashItemPicture();	
					break;				
				case 'html':
				case 'url':
					return new UrlItemPicture();	
					break;
				case 'exe':
				case 'msi':
				case 'sh':
				case 'osx':					
				case 'dmg':
					return new BinaryItemPicture();	
					break;
				case 'jpg':
				case 'jpeg':
				case 'png':
				case 'gif':					
				case 'bmp':
					return new BinaryItemPicture();	
					break;
				case 'mpg':
				case 'mpeg':
				case 'avi':
					return new BinaryItemPicture();	
					break;
				default:
					return new DefaultItemPicture();
			}
		}
	}
}