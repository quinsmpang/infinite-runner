/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 10:49 AM
 */
package ui.items {

	import citrus.ui.inventory.core.GameObject;

	public class Key extends GameObject {

		public static const POLISHED:uint = 1 << 0;
		public static const FOUND:uint = 1 << 1;

		public function Key() {
			super();
		}

		override public function init():GameObject {
			name = "ui.items.Key";
			return super.init();
		}
	}
}
