/**
 * Creates a "loading circle" similar to the one used by Apple.
 *
 * Usage {{{
 *    var lc:loader_circle = new loader_circle({color: 0x666666, height: 12, width: 3});
 *    stage.addChild(lc);
 * }}}
 */

package classes.graphics {
	import classes.geom.simple_rectangle;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;

	public class loader_circle extends Sprite {
		// Global vars
		private var _degrees:Number						= (360 / 12);
		private var _PI_angle:Number					= (Math.PI / 180);
		private var _settings:Object					= null;
		private var _timer:Timer						= null;

		/**
		 * constructor: sets up the loader circle
		 */
		public function loader_circle(settings:Object=null):void {
			super();
			
			_settings = (settings != null) ? settings : new Object();
			_settings.color = ((_settings.color != null) && (Number(_settings.color) >= 0)) ? _settings.color : 0x666666;
			_settings.height ||= 6;
			_settings.width ||= 2;
			
			_draw();
			this.addEventListener(Event.ADDED_TO_STAGE, _addedToStage, false);
		}
		
		/**
		 * listener for when the loader circle has been added to the stage to setup the timer/listeners
		 */
		private function _addedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE,	_addedToStage,		false);
			this.addEventListener(Event.REMOVED_FROM_STAGE,	_removedFromStage,	false);
			_timer = new Timer(65);
			_timer.addEventListener(TimerEvent.TIMER, _changeRotation, false, 0, true);
			_timer.start();
		}
		
		/**
		 * changes the current circle rotation
		 */
		private function _changeRotation(e:TimerEvent):void {
			this.rotation = (this.rotation + _degrees) % 360;
		}
		
		/**
		 * draws the loader circle
		 */
		private function _draw():void {
			var i:int = 12;
			while (i--) {
				var slice:Sprite = new simple_rectangle(_settings.width, _settings.height, _settings.color, 0, _settings.color, 12);
				slice.alpha = Math.max(0.2, (1 - (0.1 * i)));
				var radianAngle:Number = (_degrees * i) * _PI_angle;
				slice.rotation = -_degrees * i;
				slice.x = Math.sin(radianAngle) * _settings.height;
				slice.y = Math.cos(radianAngle) * _settings.height;
				this.addChild(slice);
			}
		}
		
		/**
		 * listener for when the loader circle has been removed from the stage to destroy the timer/listeners
		 */
		private function _removedFromStage(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE,	_removedFromStage,	false);
			this.addEventListener(Event.ADDED_TO_STAGE,			_addedToStage,		false);
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, _changeRotation);
			_timer = null;
		}
	}
}