﻿package gear.gui.controls {
	import gear.gui.cell.GCell;
	import gear.gui.cell.IGCell;
	import gear.gui.core.GBase;
	import gear.gui.core.GPhase;
	import gear.gui.core.GScaleMode;
	import gear.gui.model.GChangeList;
	import gear.gui.model.GListChange;
	import gear.gui.model.GListModel;
	import gear.gui.skins.GPanelSkin;
	import gear.gui.skins.IGSkin;
	import gear.gui.utils.GUIUtil;
	import gear.log4a.GLogger;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * 列表控件
	 * 
	 * @author bright
	 * @version 20130417
	 */
	public class GList extends GBase {
		protected var _bgSkin : IGSkin;
		protected var _content : Sprite;
		protected var _vScrollBar : GVScrollBar;
		protected var _scrollRect : Rectangle;
		protected var _selectedIndex : int;
		protected var _multipleSelection : Boolean;
		protected var _changes : GChangeList;
		protected var _model : GListModel;
		protected var _hgap : int;
		protected var _cell : Class;
		protected var _template : IGCell;
		protected var _cells : Vector.<IGCell>;
		protected var _onCellClick : Function;
		protected var _outside : Boolean;

		override protected function preinit() : void {
			_bgSkin = GPanelSkin.skin;
			_scrollRect = new Rectangle();
			_selectedIndex = -1;
			_multipleSelection = false;
			_changes = new GChangeList;
			_model = new GListModel();
			_model.onChange = onModelChange;
			_cells = new Vector.<IGCell>();
			_cell = GCell;
			_padding.dist = 1;
			_template = new _cell();
			_outside = false;
			setSize(100, 100);
		}

		override protected function create() : void {
			_bgSkin.addTo(this, 0);
			_content = new Sprite();
			_content.x = _padding.left;
			_content.y = _padding.right;
			addChild(_content);
			_vScrollBar = new GVScrollBar();
			_vScrollBar.visible = false;
			addChild(_vScrollBar);
		}

		override protected function resize() : void {
			_bgSkin.setSize(_width, _height);
			_scrollRect.width = _width - (_vScrollBar.visible ? _vScrollBar.width : 0) - _padding.left - _padding.right;
			_scrollRect.height = _height - _padding.top - _padding.bottom;
			_content.scrollRect = _scrollRect;
			_vScrollBar.x = _width - _vScrollBar.width;
			_vScrollBar.height = _height;
			callLater(updateScroll);
		}

		override protected function onShow() : void {
			addEvent(this, MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			if (_outside) {
				addEvent(stage, MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
			}
		}

		protected function stageMouseDownHandler(event : MouseEvent) : void {
			if (!GUIUtil.atParent(DisplayObject(event.target), this)) {
				dispatchEvent(new MouseEvent(MouseEvent.RELEASE_OUTSIDE));
			}
		}

		protected function mouseWheelHandler(event : MouseEvent) : void {
			_vScrollBar.value -= event.delta;
		}

		protected function onModelChange(change : GListChange) : void {
			_changes.add(change);
			callLater(updateChanges);
		}

		protected function updateChanges() : void {
			var change : GListChange;
			while (_changes.hasNext) {
				change = _changes.shift();
				switch(change.state) {
					case GListChange.RESET:
						callLater(updateCells);
						break;
					case GListChange.ADDED:
						if (change.index <= _selectedIndex) {
							_selectedIndex++;
						}
						addCell(change.index);
						moveCells(change.index + 1, _template.height);
						callLater(updateScroll);
						break;
					case GListChange.REMOVED:
						if (change.index < _selectedIndex) {
							_selectedIndex--;
						} else if (change.index == _selectedIndex) {
							selectedIndex = -1;
						}
						removeCell(change.index);
						moveCells(change.index, -_template.height);
						callLater(updateScroll);
						break;
					case GListChange.UPDATE:
						_cells[change.index].source = _model.getAt(change.index);
						break;
				}
			}
		}

		protected function updateCells() : void {
			while (_cells.length > 0) {
				removeCell(0);
			}
			var length : int = _model.length;
			for (var i : int = 0; i < length; i++) {
				addCell(i);
				updateCell(i);
			}
			selectedIndex = -1;
			callLater(updateScroll);
		}

		protected function addCell(index : int) : void {
			var cell : IGCell = new _cell();
			cell.y = index * _template.height;
			cell.width = _scrollRect.width;
			cell.source = _model.getAt(index);
			_content.addChild(DisplayObject(cell));
			_cells.splice(index, 0, cell);
			cell.addEventListener(MouseEvent.MOUSE_DOWN, cell_mouseDownHandler);
			cell.addEventListener(MouseEvent.CLICK, cell_clickHandler);
		}

		protected function removeCell(index : int) : void {
			var cell : IGCell = _cells[index];
			cell.hide();
			cell.removeEventListener(MouseEvent.MOUSE_DOWN, cell_mouseDownHandler);
			cell.removeEventListener(MouseEvent.CLICK, cell_clickHandler);
			_cells.splice(index, 1);
		}

		/**
		 * 移动单元格
		 */
		protected function moveCells(index : int, dy : int) : void {
			while (index < _cells.length) {
				_cells[index].y += dy;
				index++;
			}
		}

		protected function updateCell(index : int) : void {
			_cells[index].source = _model.getAt(index);
		}

		protected function cell_mouseDownHandler(event : MouseEvent) : void {
			selectedIndex = _cells.indexOf(IGCell(event.currentTarget));
		}

		protected function cell_clickHandler(event : MouseEvent) : void {
			if (_onCellClick != null) {
				try {
					_onCellClick(event.currentTarget);
				} catch(e : Error) {
					GLogger.debug(e.getStackTrace());
				}
			}
		}

		protected function updateScroll() : void {
			var pageSize : int = _height / _template.height;
			var max : int = _model.length - pageSize;
			if (max > 0) {
				_vScrollBar.setTo(pageSize, max, _scrollRect.y);
				if (!_vScrollBar.visible) {
					_scrollRect.width = _width - _vScrollBar.width - _padding.left - _padding.right;
					_content.scrollRect = _scrollRect;
					_vScrollBar.visible = true;
					_vScrollBar.onValueChange = onValueChange;
				}
			} else if (_vScrollBar.visible) {
				_scrollRect.width = _width - _padding.left - _padding.right;
				_content.scrollRect = _scrollRect;
				_vScrollBar.value = 0;
				_vScrollBar.visible = false;
				_vScrollBar.onValueChange = null;
			}
		}

		protected function onValueChange() : void {
			_scrollRect.y = _vScrollBar.value * _template.height;
			_content.scrollRect = _scrollRect;
		}

		public function GList() {
		}

		public function set multipleSelection(value : Boolean) : void {
			_multipleSelection = value;
		}

		public function set onCellClick(value : Function) : void {
			_onCellClick = value;
		}

		public function set bgSkin(value : IGSkin) : void {
			if (_bgSkin == null || _bgSkin == value) {
				return;
			}
			_bgSkin.remove();
			_bgSkin = value;
			_bgSkin.phase = (_enabled ? GPhase.UP : GPhase.DISABLED);
			_bgSkin.addTo(this, 0);
			if (_scaleMode == GScaleMode.FIT_SIZE) {
				forceSize(_bgSkin.width, _bgSkin.height);
			}
		}

		public function get vScrollBar() : GVScrollBar {
			return _vScrollBar;
		}

		public function set cell(value : Class) : void {
			if (_cell == value) {
				return;
			}
			_cell = value;
			_template = new _cell();
		}

		public function set model(value : GListModel) : void {
			if (value == null || _model == value) {
				return;
			}
			if (_model != null) {
				_model.removeOnChange(onModelChange);
			}
			_model = value;
			_model.onChange = onModelChange;
			callLater(updateCells);
		}

		public function get model() : GListModel {
			return _model;
		}

		public function set selectedIndex(value : int) : void {
			if (_selectedIndex == value) {
				return;
			}
			if (_multipleSelection) {
				return;
			}
			if (_selectedIndex > -1 && _selectedIndex < _cells.length) {
				_cells[_selectedIndex].selected = false;
			}
			_selectedIndex = value;
			if (_selectedIndex > -1 && _selectedIndex < _cells.length) {
				_cells[_selectedIndex].selected = true;
			}
		}

		public function get selectedIndex() : int {
			return _selectedIndex;
		}

		public function get selection() : * {
			return _model.getAt(_selectedIndex);
		}

		public function get selectedItems() : Vector.<Object> {
			var result : Vector.<Object>=new Vector.<Object>();
			for each (var cell : IGCell in _cells) {
				if (cell.selected) {
					result.push(cell.source);
				}
			}
			return result;
		}

		public function selectAll(value : Boolean) : void {
			for each (var cell : IGCell in _cells) {
				cell.selected = value;
			}
		}

		public function set outside(value : Boolean) : void {
			_outside = value;
		}
	}
}
