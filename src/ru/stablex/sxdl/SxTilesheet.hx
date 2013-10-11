package ru.stablex.sxdl;

import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Point;
import flash.geom.Rectangle;

#if (flash && !notransform)
import flash.Vector;
#end

#if haxe3
private typedef Hash<T> = Map<String,T>;
#end

/**
* Tilesheet
*
*/
class SxTilesheet #if !flash extends Tilesheet #end {

    //description
    public var _tiles : Hash<SxTile>;
    //tiles counter
    private var _cntTiles : Int = 0;
    /** description */
    public var animations : Map<String, Array<SxTile>>;

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
        this._tiles      = new Hash();
        this.animations = new Map();
    }//function new()


    /**
    * Creates tile with specified name
    *
    */
    public function createTile (name:String, rect:Rectangle, center:Point) : Void {
        this._tiles.set(name, new SxTile(this._cntTiles, rect.width, rect.height, center.x, center.y));

        #if !flash
        this.addTileRect(rect, center);
        #end

        this._cntTiles ++;
    }//function addTileRect()


#if flash

    #if !notransform
    /**
    * draw tiles
    *
    */
    public function drawTiles(graphics:flash.display.Graphics, dd:Array<Float>, vtx:Vector<Float>, idx:Vector<Int>, uv:Vector<Float>, smooth:Bool = false) : Void {
        graphics.beginBitmapFill(this.nmeBitmap, null, true, smooth);
        graphics.drawTriangles(vtx, idx, uv);
        graphics.endFill();
    }//function drawTiles()

    #else

    var screen : BitmapData;
    var pnt    : Point;
    var bmp    : BitmapData;

    /**
    * draw tiles
    *
    */
    public function drawTiles(graphics:flash.display.Graphics, dd:Array<Float>, stage:SxStage) : Void {
        if( screen == null || screen.width != stage.stageWidth || screen.height != stage.stageHeight ){
            screen = new BitmapData(stage.stageWidth, stage.stageHeight);
            pnt = new Point(0, 0);
        }

        screen.fillRect(screen.rect, 0x00000000);
        var tdata;
        for(i in 0...Std.int(dd.length / SxStage.DPT)){
            tdata = stage._tsBuilder._tileData[ Std.int(dd[i * SxStage.DPT + 2]) ];
            bmp = tdata.bmp;
            pnt.x = dd[i * SxStage.DPT] - tdata.spot.x;
            pnt.y = dd[i * SxStage.DPT + 1] - tdata.spot.y;
            screen.copyPixels(bmp, bmp.rect, pnt, null, null, true);
        }
        bmp = null;

        graphics.beginBitmapFill(screen, null, false, stage.smooth);
        graphics.drawRect(0, 0, screen.width, screen.height);
        graphics.endFill();
    }//function drawTiles()
    #end
#end

}//class SxTilesheet

