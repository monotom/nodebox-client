package nodebox.ui.windows {
	
	import flash.events.Event;
	import m.app.AppEvent;
	import m.ui.Notice;
	import nodebox.App;
	import nodebox.io.provider.ProviderInterface;
	import nodebox.plugins.PluginEvent;
	import m.ui.ChildWindow;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import spark.components.ComboBox;
	
	/**
	 * This class extends the base window class and represents a window where all log generated during runtime appear. @see m.ui.ChildWindow
	 * 
	 * @author Tom Hanoldt
	 */
	public class DebugWindow extends Notice {
		/** 
		 * Constructor.
		 */
		public function DebugWindow() {
			super(400, 300);
		}
		
		/** 
		 * This method overrides the parents createChildren method for extending the view.
		 */
		override protected function createChildren():void {
			super.createChildren();
			title = 'debug';
			
			closeButton.setVisible(true);
			minimizeButton.visible = false;
			resizeButton.visible = true;
		}
		
		/** 
		 * This method adds a message to log output.
		 * 
		 * @param msg the message to be added.
		 */
		public function addMessage(msg:String):void{
			try{
				label.text = msg + "\n"+label.text;
			}
			catch (e:Error) { }
		}
	}
}