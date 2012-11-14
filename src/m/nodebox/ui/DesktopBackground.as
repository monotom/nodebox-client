package m.nodebox.ui{		
	import m.app.AppEvent;
	import m.nodebox.App;
	import mx.binding.utils.BindingUtils;
	import spark.components.SkinnableContainer;
	import spark.components.TextArea;

	/**
	 * This class represents the Background of the Desktop.
	 * 
	 */
	public class DesktopBackground extends SkinnableContainer{		
		public var text:TextArea = new TextArea();
		
		public function DesktopBackground():void {	
			App.instance.addEventListener(AppEvent.ON_APP_COMPLEETE, onAppCompleete);
		}
		
		private function onAppCompleete(e:AppEvent):void {
			text.width = 600;
			addElement(text);
			App.instance.logger.info('width:'+App.instance.window.width+'');
			width = App.instance.window.width;
			height = App.instance.window.height;
			
			BindingUtils.bindProperty(this, "width", App.instance.window, "width");					
			BindingUtils.bindProperty(this, "height", App.instance.window, "height");
			
			setStyle('backgroundColor', '#0000aa'); 
		}
		/*		TODO read from desktop.configItem
		public function update(desktopElement:DesktopElement):void
		{			
			this.desktopElement = desktopElement;
						
			if(!desktopElement.vo.resourceUrl)
				return;
			
			removeAllElements();
			trace("bg0");
			
			//background image 
			if(desktopElement.vo.resourceUrl.substr(0,1) == '#')
			{	trace("bg1");		
				x = 0;
				y = 0;
				setStyle('backgroundColor', desktopElement.vo.resourceUrl); 

			}
			if(desktopElement.vo.additional.substr(0,1) == '#')
			{	trace("bg2");	
				x = 0;
				y = 0;				
				setStyle('backgroundColor', desktopElement.vo.additional); 
			}
			
			//image from web or local
			if(desktopElement.getExtension())
			{		
				switch(desktopElement.getExtension())
				{
					case 'png':
					case 'gif':
					case 'jpeg':					
					case 'jpg':
					case 'swf':			
						var img:Image = new Image();
						img.load(desktopElement.vo.resourceUrl);
						img.x=desktopElement.vo.x;
						img.y=desktopElement.vo.y;
						addElement(img);	
						return ;
				}
			}
			
			//web page
			if(desktopElement.vo.resourceUrl.lastIndexOf('http://') != -1)
			{			
				var webPage:HTML = new HTML();
				webPage.location = desktopElement.vo.resourceUrl;
				webPage.x=desktopElement.vo.x;
				webPage.y=desktopElement.vo.y;
				addElement(webPage);
			}						
		}*/
	}
}