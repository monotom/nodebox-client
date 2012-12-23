package nodebox.ui.viewer{
	import flash.events.Event;
	import flash.net.URLRequest;
	import m.net.UIHtmlLoader;
	import m.ui.ChildWindow;
	import mx.binding.utils.BindingUtils;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.controls.HTML;
	import mx.controls.scrollClasses.ScrollBar;

	public class WebBrowserWindow extends ChildWindow{
		//private var htmlLoader:UIHtmlLoader;
		//private var scrollContainer:HBox;
		
		public function WebBrowserWindow():void{
			super();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			/*if (htmlLoader == null) {
				scrollContainer = new HBox();
				htmlLoader = new UIHtmlLoader();
				
				
				//htmlLoader.width = scrollContainer.width = 640;
				//htmlLoader.height = scrollContainer.height = 480;
				//htmlLoader.scaleX = htmlLoader.scaleY = 1;
				
				scrollContainer.addElement(htmlLoader);
				scrollContainer.horizontalScrollPolicy = scrollContainer.verticalScrollPolicy = 'on';
				addElement(scrollContainer);
				var b:HTML
				// binds a 'text' field on a text-box labeled 'nameBox' to
				// the property 'firstName' on some object 'someUser'
				BindingUtils.bindProperty(this, "width", scrollContainer, "width");
				BindingUtils.bindProperty(this, "height", scrollContainer, "height");
				BindingUtils.bindProperty(scrollContainer, "width", htmlLoader, "width");
				BindingUtils.bindProperty(scrollContainer, "height", htmlLoader, "height");
				
				
				htmlLoader.addEventListener(Event.COMPLETE, completeHandler);
			}*/
			//BindingUtils.bindProperty(parent, "width", this, "width");
			//BindingUtils.bindProperty(parent, "height", this, "height");
				
		}
		[Bindable]
		public var loader:HTML;
		
		public function load(request:URLRequest):void {
			//if(htmlLoader == null)
				//createChildren();
			
			title = request.url;	
				
			loader.htmlLoader.load(request);
		}
		
		private function completeHandler(event:Event) : void{
			dispatchEvent(new Event(Event.COMPLETE));	
		//	this.invalidateSize();
		}
		
		public var controlls:ControlBar;
		public function set hideControlls(value:Boolean):void {
			controlls.visible = value;
		}
	}
}