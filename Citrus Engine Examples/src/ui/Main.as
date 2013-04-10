/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 4:41 PM
 */
package ui {

	import citrus.core.CitrusEngine;

	public class Main extends CitrusEngine {
		
		public function Main() {
			
			state = new InventoryState();
		}
	}
}
