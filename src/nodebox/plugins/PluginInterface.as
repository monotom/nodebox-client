package nodebox.plugins {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public interface PluginInterface {
		/** 
		 * Get the plugin name.
		 * 
		 * @return The name of the plugin.
		 */
		function getName():String;
		
		/** 
		 * Get the event and dispatcher map for this plugin. This map is used to register the dispatchers on the application object. @see nodebox.App
		 */
		function getSupportedEvents():Array;
	}
}