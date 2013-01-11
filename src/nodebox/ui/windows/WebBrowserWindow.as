package nodebox.ui.windows{
	import flash.events.Event;
	import flash.net.URLRequest;
	import m.ui.ChildWindow;
	import mx.containers.ControlBar;
	import mx.controls.HTML;

	/**
	 * This class extends the base window class and builds a simple web browser inside the application. @see m.ui.ChildWindow
	 * 
	 * @author Tom Hanoldt
	 */
	public class WebBrowserWindow extends ChildWindow{
		[Bindable]
		public var loader:HTML;
		
		/** 
		 * This method starts loading a url request inside the browser.
		 * 
		 * @param request The url request to load the page content from.
		 */
		public function load(request:URLRequest):void {
			title = request.url;	
				
			loader.htmlLoader.load(request);
		}
		
		/** 
		 * This method dispatches a compleete event if a url request is loaded.
		 * 
		 * @param event The event that triggered that method.
		 */
		private function completeHandler(event:Event) : void{
			dispatchEvent(new Event(Event.COMPLETE));	
		}
		
		public var controlls:ControlBar;
		/** 
		 * This method can be used to hide or show the browser controll buttons.
		 * 
		 * @param value Indicates if to hide or to show the controlls.
		 */
		public function set hideControlls(value:Boolean):void {
			controlls.visible = value;
		}
	}
}