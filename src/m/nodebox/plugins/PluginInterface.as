package m.nodebox.plugins {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public interface PluginInterface {
		function getName():String;
		
		function getSupportedEvents():Array;
	}
}