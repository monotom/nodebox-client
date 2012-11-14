package m.nodebox.io {
	import flash.events.Event;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class IOEvent extends Event{
		public static const ON_FILE_CREATE:String 	= 'io.file.create';
		public static const ON_FILE_CREATED:String 	= 'io.file.created';
		public static const ON_FILE_DELETE:String 	= 'io.file.delete';
		public static const ON_FILE_DELETED:String 	= 'io.file.deleted';
		public static const ON_FILE_CHANGE:String 	= 'io.file.change';
		public static const ON_FILE_CHANGED:String 	= 'io.file.changed';
		public static const ON_FILE_MOVE:String 	= 'io.file.move';
		public static const ON_FILE_MOVED:String 	= 'io.file.moved';
		public static const ON_FILE_COPPY:String 	= 'io.file.coppy';
		public static const ON_FILE_COPPIED:String 	= 'io.file.coppied';
		public static const ON_FOLDER_CREATE:String = 'io.folder.create';
		public static const ON_FOLDER_CREATED:String 		= 'io.folder.created';
		public static const ON_FILE_INFO_REQUEST:String 	= 'io.file.info.request';
		public static const ON_FILE_INFO_RESPONSE:String 	= 'io.file.info.response';
		
		public var item:Item;
		public function IOEvent(type:String, item:Item = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.item = item;
		}
	}
}