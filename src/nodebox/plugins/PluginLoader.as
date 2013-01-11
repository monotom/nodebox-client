package nodebox.plugins {
	import nodebox.App;
	
	import nodebox.io.provider.*;
	import nodebox.plugins.*;
	/**
	 * This class is used to hold all plugins and data providers taht should be registered by the applocation object. @see nodebox.App
	 * If there where comming new plugins or dataproviders they have to added here.
	 * 
	 * @author Tom Hanoldt
	 */
	public class PluginLoader {	
		/** 
		 * This method returns all available plugins.
		 * 
		 * @return Array of plugins.
		 */
		public static function getPlugins():Array {
			return [new DesktopViewStateHandler(),
					new DesktopItemHandler(),
					new DesktopItemContextMenu(),
					new AppDebugWindow(),
					new AppErrorAlert(),
					new DesktopLogout(),
					new AppProviderBranding(),
					new AppHelpLink()
					];
		}
		
		/** 
		 * This method returns all available data providers.
		 * 
		 * @return Array of data providers.
		 */
		public static function getDataProvider():Array {
			return [new Nodebox(),
					new DropBox()];
		}
	}
}