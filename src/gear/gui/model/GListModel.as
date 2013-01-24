﻿package gear.gui.model {
	import gear.log4a.GLogger;

	/**
	 * @author bright
	 */
	public class GListModel {
		protected var _source : Vector.<Object>;
		protected var _change : Vector.<Function>;

		protected function change(value : GChange) : void {
			for each (var change:Function in _change) {
				try {
					change.apply(null, [value]);
				} catch(e : Error) {
					GLogger.error(e.getStackTrace());
				}
			}
		}

		public function GListModel() {
			_change = new Vector.<Function>();
		}

		public function get length() : int {
			return _source == null ? 0 : _source.length;
		}

		public function add(value : *) : void {
			if (_source == null) {
				return;
			}
			var index : int = _source.push(value) - 1;
			change(new GChange(GChange.ADDED, index));
		}

		public function remove(value : *) : void {
			if (_source == null) {
				return;
			}
			var index : int = _source.indexOf(value);
			if (index == -1) {
				return;
			}
			_source.splice(index, 1);
			change(new GChange(GChange.REMOVED, index));
		}

		public function addAt(index : int, value : *) : void {
			if (_source == null || index < 0) {
				return;
			}
			_source.splice(index, 0, value);
			change(new GChange(GChange.ADDED, index));
		}

		public function removeAt(index : int) : void {
			if (_source == null || index < 0 || index >= _source.length) {
				return;
			}
			_source.splice(index, 1);
			change(new GChange(GChange.REMOVED, index));
		}

		public function setAt(index : int, value : *) : void {
			if (_source == null || index < 0 || index >= _source.length) {
				return;
			}
			_source[index] = value;
			change(new GChange(GChange.UPDATE, index));
		}

		public function getAt(value : int) : * {
			if (_source == null || value < 0 || value >= _source.length) {
				return null;
			}
			return _source[value];
		}

		public function clear() : void {
			_source.length = 0;
			change(new GChange(GChange.RESET));
		}

		public function set onChange(value : Function) : void {
			if (_change.indexOf(value) == -1) {
				_change.push(value);
			}
		}

		public function removeOnChange(value : Function) : void {
			var index : int = _change.indexOf(value);
			if (index != -1) {
				_change.splice(index, 1);
			}
		}

		public function set source(value : Object) : void {
			if (_source == value) {
				return;
			}
			_source = Vector.<Object>(value);
			change(new GChange(GChange.RESET));
		}
	}
}
