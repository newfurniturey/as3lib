/**
 * Creates and returns a reflection of the specified MovieClip.
 *
 * Usage: {{{
 *    var refl:reflection = new reflection();
 *    var myReflection:MovieClip = refl.reflect(myRegularClip);
 * }}}
 */

package classes.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public class reflection extends MovieClip {
		/**
		 * reflects the specified MovieCip
		 */
		public function reflect(clip:MovieClip):MovieClip {
			var reflected:MovieClip = new MovieClip();
			
			// get a copy of the clip's bitmapdata
			var clip_bmpdata:BitmapData = (clip is image_tile) ? BitmapData(clip.bitmapData()) : BitmapData(clip.bitmapData).clone();
			
			// create the bitmap that will be the actual "reflected" clip
			var clip_bmp:Bitmap		= new Bitmap(clip_bmpdata);
			clip_bmp.scaleY			= -1;				// turn the bitmap upside down (for the "reflection")
			clip_bmp.y				= clip_bmp.height;	// because we flipped it, we need to re-offset it's y
			clip_bmp.cacheAsBitmap	= true;				// cache this bad boy as a bitmap (yea, i know...)
			reflected.addChild(clip_bmp);				// add 'er to the new reflected clip
			
			// create the gradient "mask" that will fade the reflection out
			var grad_mask:MovieClip = new MovieClip();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(clip_bmp.width, (clip_bmp.height / 2), (Math.PI / 2), 0, 0);
			grad_mask.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [.9, 0], [0, 200], matrix, SpreadMethod.PAD);
			grad_mask.graphics.drawRect(0, 0, clip_bmp.width, clip_bmp.height);
			grad_mask.cacheAsBitmap = true;
			reflected.addChild(grad_mask);
			
			// mask the object and return it!
			clip_bmp.mask = grad_mask;
			return reflected;
		}
	}
}