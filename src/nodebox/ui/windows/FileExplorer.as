package nodebox.ui.windows
{
	import sd.app.DesktopElement;
	import sd.ui.ChildWindowClass;

	public class FileExplorer extends ChildWindowClass
	{
		private var desktopElement:DesktopElement;
		
		public function FileExplorer(desktopElement:DesktopElement):void
		{
			this.desktopElement = desktopElement;
		}
	}
}