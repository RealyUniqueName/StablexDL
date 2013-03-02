package ru.stablex.sxdl;

import nme.Assets;
import nme.display.Tilesheet;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.display.BitmapData;


/**
* Tilesheet builder
* @private
*/
class SxTsBuilder{
    //used to pack tiles into tilesheet
    static public var CELL_SIZE : Int = 8;

    //list of registered tiles
    public var tiles : Hash<SxTile>;
    public var _tileData : Array<TileData>;
    //tile counter
    public var cntTiles : Int = 0;
    //description
    public var locked (default,null) : Bool = false;


    /**
    * Sort tiles
    *
    */
    static private function _tileSorter (t1:TileData, t2:TileData) : Int {
        //sort by size
        if(t1.bmp.width * t1.bmp.height > t2.bmp.width * t2.bmp.height) return -1;
        if(t1.bmp.width * t1.bmp.height < t2.bmp.width * t2.bmp.height) return 1;

        // //sort by height
        // if(t1.bmp.height > t2.bmp.height) return -1;
        // if(t1.bmp.height < t2.bmp.height) return 1;

        return 0;
    }//function _tileSorter()


    /**
    * Constructor
    *
    */
    public function new () : Void {
        this.tiles  = new Hash();
        this._tileData = [];
    }//function new()


    /**
    * Add sprite to tilesheet
    *
    * @param name - name for sprite or asset ID of bitmap to use;
    * @param bmp - asset id of bitmap or BitmapData instance. Leave null if you want to use `name` as asset id;
    * @param spotX - x for center point of sprite (-1 for half of bitmap width);
    * @param spotY - y for center point of sprite (-1 for half of bitmap height);
    * @param clipAlpha - use `bitmapData.getColorBoundsRect()` ?
    * @param sourceSizeForSpot - take center point coordinates in source sprite size or in clipped sprite size;
    * @param smooth - smooth bitmap if `scale` != 1
    */
    public function addSprite (name:String, bmp:Dynamic = null, scale:Float = 1, spotX:Null<Float> = null, spotY:Null<Float> = null, clipAlpha:Bool = false, sourceSizeForSpot:Bool = true, smooth:Bool = true) : Void {
        if( this.locked ) throw "Tilesheet is locked";

        var src  : BitmapData = (
            bmp != null
                ? (Std.is(bmp, BitmapData) ? bmp : Assets.getBitmapData(Std.string(bmp), false))
                : Assets.getBitmapData(name, false)
        );
        var data : TileData = new TileData();

        data.name = name;

        if( spotX == null ) spotX = src.width / 2;
        if( spotY == null ) spotY = src.height / 2;

        #if neko
        var rect : Rectangle = (clipAlpha ? src.getColorBoundsRect({a:0xFF, rgb:0x000000}, {a:0x00, rgb:0x000000}, false) : src.rect);
        #else
        var rect : Rectangle = (clipAlpha ? src.getColorBoundsRect(0xFF000000, 0x00000000, false) : src.rect);
        #end
        data.spot = (sourceSizeForSpot ? new Point( (spotX - rect.x) * scale, (spotY - rect.y) * scale ) : new Point(spotX * scale, spotY * scale));

        //if scaling or clipping is set, create new bitmapData
        if( clipAlpha || scale != 1 ){
            #if neko
                data.bmp = new BitmapData(Math.ceil(rect.width * scale), Math.ceil(rect.height * scale), true, {a:0x00, rgb:0x000000});
            #else
                data.bmp = new BitmapData(Math.ceil(rect.width * scale), Math.ceil(rect.height * scale), true, 0x00000000);
            #end

            if( scale == 1 ){
                data.bmp.copyPixels(src, rect, new Point(0, 0));
            }else{
                var mx : Matrix = new Matrix();
                mx.scale(scale, scale);
                data.bmp.draw(src, mx);
            }

        //use original bitmapData
        }else{
            data.bmp = src;
        }

        this._tileData.push(data);
    }//function addSprite()


    /**
    * Build tilesheet bitmap and prevent adding new sprites
    *
    */
    public function getTilesheet () : SxTilesheet {
        #if debug
            if( this._tileData.length == 0 ){
                throw "No sprites were added. Use stage.addSprite() to add at least one.";
            }
        #end

        this.locked = true;

        //sort tiles by size
        this._tileData.sort(SxTsBuilder._tileSorter);

        //perfect tilesheet size
        var perfect : Int = 0;
        for(data in this._tileData){
            perfect += data.bmp.width * data.bmp.height;
        }

        //build tilesheet bitmap
        #if (flash && notransform)
        var bmp : BitmapData = new BitmapData(1, 1);
        #else
        var bmp : BitmapData = this._packTiles(Math.ceil(Math.sqrt(perfect) / 256) * 256, [[0]], 0);
        #end

        var ts : SxTilesheet = new SxTilesheet(bmp);

        //create tile rects
        for(data in this._tileData){
            ts.createTile(data.name, new Rectangle(data.pos.x, data.pos.y, data.bmp.width, data.bmp.height), data.spot);
            #if (flash && !notransform)
                data.rect = new Rectangle(data.pos.x, data.pos.y, data.bmp.width, data.bmp.height);
            #end
            #if !(flash && notransform)
            data.bmp = null;
            #end
        }

        return ts;
    }//function getTilesheet()


    /**
    * Find smallest rectangle to pack tiles. Start with provided size.
    *
    */
    private function _packTiles (size:Int, cells:Array<Array<Int>>, startTileDataIdx:Int) : BitmapData {
        var newCells : Int = Math.ceil(size / CELL_SIZE);

        //increase cells to specified size
        for(c in 0...newCells){
            if( cells.length <= c ) cells.push([0]);

            for(r in cells[c].length...newCells){
                cells[c].push(0);
            }
        }

        //try to place all tiles{
            var cols  : Int;
            var rows  : Int;
            var found : Bool = false;
            var data  : TileData;

            for(i in startTileDataIdx...this._tileData.length){
                data  = this._tileData[i];
                found = false;

                cols = Math.ceil(data.bmp.width / CELL_SIZE);
                rows = Math.ceil(data.bmp.height / CELL_SIZE);

                for(c in 0...newCells){
                    data.pos.x = c * CELL_SIZE;
                    if( data.pos.x + data.bmp.width > size ){
                        return this._packTiles(size + 256, cells, i);
                    }

                    var r : Int = 0;
                    while(r < newCells){
                        data.pos.y = r * CELL_SIZE;
                        if(data.pos.y + data.bmp.height > size) break;
                        found = true;

                        //check, there are enough free columns and rows for tile in this pos
                        for(col in c...(c + cols)){
                            for(row in r...(r + rows)){
                                if( cells[col][row] == 1 ){
                                    found = false;
                                    r = row + 1;
                                    break;
                                }
                            }

                            if( found == false ) break;
                        }

                        //found a place for tile. Mark cells as occupied
                        if( found ){
                            for(col in c...(c + cols)){
                                for(row in r...(r + rows)){
                                    cells[col][row] = 1;
                                }
                            }

                            break;
                        }

                        r++;
                    }//while( rows )

                    if( found ) break;
                }//for( columns )
            }//for( tileData )
        //}

        //create bitmap for tilesheet{
            #if neko
                var bmp : BitmapData = new BitmapData(size, size, true, {a:0x00, rgb:0x000000});
            #else
                var bmp : BitmapData = new BitmapData(size, size, true, 0x00000000);
            #end
            for(data in this._tileData){
                bmp.copyPixels(data.bmp, data.bmp.rect, new Point(data.pos.x, data.pos.y));
            }
        //}

        return bmp;
    }//function _packTiles()

}//class SxTsBuilder


/**
* Data from SxTsBuilder.addSprite() for creating SxTile instances
* @private
*/
class TileData {

    //sprite's bitmapData
    public var bmp : BitmapData;
    //center point of sprite
    public var spot : Point;
    //unique name
    public var name : String;
    //tile position on tilesheet bitmap
    public var pos : {x:Int, y:Int};
    #if (flash && !notransform)
    public var rect : Rectangle;
    #end

    /**
    * Constructor
    *
    */
    public function new () : Void {
        this.pos = {x:0, y:0};
    }//function new()
}//class TileData