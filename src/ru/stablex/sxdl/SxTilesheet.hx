package ru.stablex.sxdl;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;



/**
* Tilesheet
*
*/
class SxTilesheet #if !flash extends Tilesheet #end {

    //description
    public var _tiles : Hash<SxTile>;
    //tiles counter
    private var _cntTiles : Int = 0;

    #if flash
        public var pnt : Point;
        #if !notransform
            public var mx : Matrix;
        #end
        public var nmeBitmap : BitmapData;
    #end

    /**
    * Constructor
    *
    */
    public function new (bmp:BitmapData) : Void {
        #if flash
            this.nmeBitmap = bmp;
            #if !notransform
                this.mx = new Matrix();
            #end
        #else
            super(bmp);
        #end
        this._tiles = new Hash();
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
    public function drawTiles(graphics:nme.display.BitmapData, dd:Array<Float>, stage:SxStage, smooth:Bool = false) : Void {

        graphics.lock();
        graphics.fillRect(graphics.rect, 0x00000000);

        var tdata;
        for(i in 0...Std.int(dd.length / SxStage.DPT)){
            tdata = stage._tsBuilder._tileData[ Std.int(dd[i * SxStage.DPT + 2]) ];
            mx.tx = dd[i * SxStage.DPT + 0];
            mx.ty = dd[i * SxStage.DPT + 1];
            mx.a  = dd[i * SxStage.DPT + 3];
            mx.c  = dd[i * SxStage.DPT + 4];
            mx.b  = dd[i * SxStage.DPT + 5];
            mx.d  = dd[i * SxStage.DPT + 6];
            pnt = mx.deltaTransformPoint(tdata.spot);
            mx.translate(-pnt.x, -pnt.y);
            graphics.draw(tdata.bmp, this.mx, null, null, null, smooth);
        }

        graphics.unlock();
    }//function drawTiles()

    #else

    var screen : BitmapData;
    var bmp    : BitmapData;

    /**
    * draw tiles
    *
    */
    public function drawTiles(graphics:nme.display.Graphics, dd:Array<Float>, stage:SxStage) : Void {
        if( screen == null || screen.width != stage.stageWidth || screen.height != stage.stageHeight ){
            screen = new BitmapData(stage.stageWidth, stage.stageHeight);
            pnt = new nme.geom.Point(0, 0);
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

