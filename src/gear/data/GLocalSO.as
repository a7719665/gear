﻿package gear.data {
	import gear.log4a.GLogger;

	import flash.events.NetStatusEvent;
	import flash.net.ObjectEncoding;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.system.Security;
	import flash.system.SecurityPanel;

	/**
	 * 本地共享对象类
	 * 
	 * @author bright
	 * @version 20130110
	 */
	public class GLocalSO {
		private var _shareObject : SharedObject;

		private function netStatusHandler(event : NetStatusEvent) : void {
			_shareObject.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			switch(event.info.code) {
				case SharedObjectFlushStatus.FLUSHED:
					break;
				case SharedObjectFlushStatus.PENDING:
					break;
				default:
					break;
			}
		}

		/**
		 * 构造函数
		 * 
		 * @param name 本地对象名称
		 */
		public function GLocalSO(name : String) {
			_shareObject = SharedObject.getLocal(name);
			_shareObject.objectEncoding = ObjectEncoding.AMF3;
		}

		public function showSetting() : void {
			Security.showSettings(SecurityPanel.LOCAL_STORAGE);
		}

		/**
		 * setAt 设置键值
		 * 
		 * @param key 键
		 * @param value 值
		 * @example 
		 * <listing version="3.0">
		 * var lso:GLocalSO=new GLocalSO("game");
		 * lso.setAt("key","value");
		 * lso.flush();
		 * </listing>
		 */
		public function setAt(key : String, value : *) : void {
			if (value != null) {
				_shareObject.setProperty(key, value);
			} else {
				delete _shareObject.data[key];
			}
		}

		/**
		 * getAt 获得键值
		 * 
		 * @param key 键
		 * @example 
		 * <listing version="3.0">
		 * var lso:GLocalSO=new GLocalSO("game")
		 * trace(lso.getAt("key")); // 如果flush成功则输出"value"
		 * </listing>
		 * @see #setAt()
		 */
		public function getBy(key : String) : * {
			return _shareObject.data[key];
		}

		/**
		 * 保存数据到本地对象
		 * 
		 * @return Boolean 成功
		 */
		public function flush() : Boolean {
			var done : Boolean = true;
			try {
				var result : Object = _shareObject.flush();
				if (result == SharedObjectFlushStatus.FLUSHED) {
				} else if (result == SharedObjectFlushStatus.PENDING) {
					_shareObject.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
					done = false;
				}
			} catch(e : Error) {
				done = false;
				GLogger.error(e.getStackTrace());
			}
			return done;
		}

		/**
		 * 清除此本地对象中的所有数据
		 */
		public function clear() : void {
			_shareObject.clear();
		}
	}
}
