package m.nodebox.plugins {
	/**
	 * ...
	 * @author Tom Hanoldt
	 */
	public class SyncedPlugin extends AbstractPlugin {
		private var proxiedPlugin:AbstractPlugin;
		public function SyncedPlugin(proxiedPlugin:AbstractPlugin) {
			this.proxiedPlugin = proxiedPlugin;
		}
	}
}