package ru.stablex.sxdl;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;

#if flash
import nme.Vector;
#end


/**
* Tilesheet
*
*/
class SxTilesheet #if !flash extends Tilesheet #end {

    //description
    public var tiles : Hash<SxTile>;
    //tiles counter
    private var _cntTiles : Int = 0;

    #if flash
        public var nmeBitmap : BitmapData;
    #end

    /**
    * Constructor
    *
    */
    public function new (bmp:BitmapData) : Void {
        #if flash
            this.nmeBitmap = bmp;
        #else
            super(bmp);
        #end
        this.tiles = new Hash();
    }//function new()


    /**
    * Creates tile with specified name
    *
    */
    public function createTile (name:String, rect:Rectangle, center:Point) : Void {
        this.tiles.set(name, new SxTile(this._cntTiles, rect.width, rect.height, center.x, center.y));

        #if !flash
        this.addTileRect(rect, center);
        #end

        this._cntTiles ++;
    }//function addTileRect()


#if flash

    /**
    * draw tiles
    *
    */
    public function drawTiles(graphics:nme.display.Graphics, dd:Array<Float>, vtx:Vector<Float>, idx:Vector<Int>, uv:Vector<Float>, smooth:Bool = false) : Void {
        graphics.beginBitmapFill(this.nmeBitmap, null, true, smooth);
        graphics.drawTriangles(vtx, idx, uv);
        graphics.endFill();
    }//function drawTiles()
#end

}//class SxTilesheet

