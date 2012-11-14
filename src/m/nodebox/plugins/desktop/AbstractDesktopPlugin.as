package m.nodebox.plugins.desktop {
	import flash.utils.getQualifiedSuperclassName;
	import m.nodebox.plugins.PluginInterface;
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class AbstractDesktopPlugin implements PluginInterface{
		public function getName():String {
			return getQualifiedSuperclassName(this);
		}
		
		public function getSupportedEvents():Array {
			return [];
		}
	}
}