package ru.stablex.sxdl;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;


/**
* Tilesheet
*
*/
class SxTilesheet extends Tilesheet{

    //description
    public var tiles : Hash<SxTile>;
    //tiles counter
    private var _cntTiles : Int = 0;


    /**
    * Constructor
    *
    */
    public function new (bmp:BitmapData) : Void {
        super(bmp);
        this.tiles = new Hash();
    }//function new()


    /**
    * Creates tile with specified name
    *
    */
    public function createTile (name:String, rect:Rectangle, center:Point) : Void {
        this.tiles.set(name, new SxTile(this._cntTiles, rect.width, rect.height, center.x, center.y));

        this.addTileRect(rect, center);
        this._cntTiles ++;
    }//function addTileRect()
}//class SxTilesheet

