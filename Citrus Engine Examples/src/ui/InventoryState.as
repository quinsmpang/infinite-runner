/**
 * User: Makai Media Inc.
 * Date: 2/6/13
 * Time: 4:42 PM
 */
package ui {

	import citrus.core.State;
	import citrus.ui.inventory.core.InventoryManager;

	import ui.items.Car;
	import ui.items.Key;

	import flash.text.TextField;

	public class InventoryState extends State {

		public function InventoryState() {
			var textField:TextField = new TextField();
			textField.text = "";
			textField.width = 500;
			addChild(textField);

			var inventory:InventoryManager = InventoryManager.getInstance();

			inventory.add(new Car().init());
			inventory.add(new Key().init());

			textField.appendText("Is key shiny? " + inventory.status("ui.items.Key", Key.POLISHED) + "\n");

			inventory.toggleState("ui.items.Key", Key.POLISHED);

			textField.appendText("Is key shiny? " + inventory.status("ui.items.Key", Key.POLISHED) + "\n");

			textField.appendText("Can I open the car if the key is shiny? " + inventory.status("ui.items.Car", Car.UNLOCKED) + "\n");

			inventory.toggleState("ui.items.Key", Key.FOUND);

			textField.appendText("Can I open the car because I found the key, but haven't unlocked it? " + inventory.status("ui.items.Car", Car.UNLOCKED) + "\n");

			if (inventory.status("ui.items.Key", Key.FOUND)) {
				inventory.toggleState("ui.items.Car", Car.UNLOCKED);
			}

			textField.appendText("Now is the car open? " + inventory.status("ui.items.Car", Car.UNLOCKED) + "\n");

			inventory.add(new Key().init());

			textField.appendText("How many keys? " + inventory.get("ui.items.Key").quantity + "\n");

		}
	}
}
