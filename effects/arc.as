/**
 * Handles the arcing of MovieClip objects.
 *
 * Usage: {{{
 *    var archer:arc = new arc;
 *    var myArchedClip:MovieClip = archer.arc_object(myNonArchedClip, 150);
 * }}}
 */

package classes.effects {
	import classes.events.custom_event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class arc extends Sprite {
		// Global vars
		private static var _arcing:Boolean		= new Boolean(false);			// flag to indicate if we are arcing or not
		private static const max_angle:Number	= new Number(300);				// maximum (and negative minimum) arc angle
		private static const PI:Number			= new Number(Math.PI);			// global PI contant
		
		/**
		 * constructor: arcs the specified object using the specified angle
		 */
		public function arc_object(obj:Object, angle:Number):MovieClip {
			if (_arcing) return null;
			_arcing = true;
			
			// validate the given angle
			angle = ((angle >= -max_angle) && (angle <= max_angle)) ? angle : ((angle < 0) ? -max_angle : max_angle);

			// create width/height variables to relinquish overhead of lookups
			var height:Number	= obj.height;
			var width:Number	= obj.width;
			
			// make a copy of the object using its BitmapData only
			try {
				var obj_bmp:BitmapData = new BitmapData(width, height, true, 0x00000000);
				obj_bmp.draw(DisplayObject(obj));
			} catch (e:ArgumentError) {
				_finish_arc();
				trace("[arc] Error. Cannot create original BitmapData.");
				return null;
			}

			// create the arc_clip to store the slices
			var arc_clip:MovieClip = new MovieClip();
			
			var error_count:int = new int(0);
			// loop thru the entire width of the object copying/arcing a single pixel at a time
			for(var i:int=0; i<width; i++){
				// make a new "slice" that is 1-pixel wide and transparent
				try {
					var slice:BitmapData = new BitmapData(1, height, true, 0x00000000);
				} catch (e:ArgumentError) {
					_finish_arc();
					trace("[arc] Error. Cannot create slice.");
					return null;//new MovieClip();
				}

				// setup the x/y position for the new slice
				var slice_x:Number	= i;
				var slice_y:Number	= (width * Math.sin(PI * (i / width))) * (angle / 1000);
				
				// create a rectangle "where" we want to copy in the give object
				var rect:Rectangle = new Rectangle(slice_x, 0, 1, height);

				// copy the specified rectangle area from the object
				slice.copyPixels(obj_bmp, rect, new Point(0,0));
				var slice_bitmap:Bitmap = new Bitmap(slice, PixelSnapping.AUTO, false);
				
				// position the new slice
				slice_bitmap.x = slice_x;
				slice_bitmap.y = slice_y;
				
				// add the slice to the new arc_clip
				arc_clip.addChild(slice_bitmap);
			}
			
			_finish_arc();
			return arc_clip;
		}
		
		/**
		 * dispatches an event noting that the object has finished rendering
		 */
		private function _finish_arc():void {
			_arcing = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}