package nodebox.ui{		
	import m.app.AppConfig;
	import m.app.AppEvent;
	import mx.binding.utils.BindingUtils;
	import nodebox.App;
	import spark.components.SkinnableContainer;

	/**
	 * This class represents the Background of the Desktop. To this object the desktop items are added. The controll of the display takes a desktop plugin. @see DesktopViewStateHandler
	 */
	public class DesktopBackground extends SkinnableContainer{		
		/** 
		 * Constructor.
		 */
		public function DesktopBackground():void {	
			App.instance.addEventListener(AppEvent.ON_APP_COMPLEETE, onAppCompleete);
		}
		
		/** 
		 * This method is called when the nodebox app is compleetly initialized and sets the bounds and the color of the background.
		 * 
		 * @param e The app event which is dispatched when the application is initialized.
		 */
		private function onAppCompleete(e:AppEvent):void {
			width = App.instance.window.width;
			height = App.instance.window.height;
			
			BindingUtils.bindProperty(this, "width", App.instance.window, "width", true, false);					
			BindingUtils.bindProperty(this, "height", App.instance.window, "height", true, false);
			
			setStyle('backgroundColor', '#'+AppConfig.xml.app.colors.desktopBgColor); 
		}
	}
}