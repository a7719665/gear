﻿package gear.gui.model {
	/**
	 * @author bright
	 */
	public class GChange {
		public static const RESET : int = 0;
		public static const UPDATE : int = 1;
		public static const ADDED : int = 2;
		public static const REMOVED : int = 3;
		protected var _state : int;
		protected var _index : int;

		public function GChange(state : int, index : int = -1) : void {
			_state = state;
			_index = index;
		}

		public function get state() : int {
			return _state;
		}

		public function get index() : int {
			return _index;
		}
	}
}
