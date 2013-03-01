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

        // var d    : Int = 0;
        // var u    : Int = 0;
        // var v    : Int = 0;
        // var i    : Int = 0;
        // var idx  : Int = 0;
        // var tile : Int;
        // var red  : Float;
        // var green: Float;
        // var blue : Float;
        // var alpha: Float;
        // var rect : Rectangle;
        // var mx   : Matrix = new Matrix();

        // var topLeft    : Point = new Point(0, 0);
        // var topRight   : Point = new Point(0, 0);
        // var bottomLeft : Point = new Point(0, 0);
        // var bottomRight: Point = new Point(0, 0);
        // var diff       : Point = new Point(0, 0);

        // while(d < dd.length ){
        //     mx.identity();

        //     topLeft.x = dd[ d++ ];
        //     topLeft.y = dd[ d++ ];
        //     tile  = Std.int(dd[ d++ ]);
        //     mx.a  = dd[ d++ ];
        //     mx.c  = dd[ d++ ];
        //     mx.b  = dd[ d++ ];
        //     mx.d  = dd[ d++ ];
        //     red   = dd[ d++ ];
        //     green = dd[ d++ ];
        //     blue  = dd[ d++ ];
        //     alpha = dd[ d++ ];

        //     rect = this.rects[tile];

        //     //смещение относительно точки регистрации тайла на тайлсете {
        //         diff = mx.transformPoint(this.spots[tile]);

        //         topLeft.x -= diff.x;
        //         topLeft.y -= diff.y;
        //     //}

        //     //получаем координаты вершин результирующего изображения
        //         topRight.x = mx.tx + rect.width;
        //         topRight.y = mx.ty;
        //         topRight = mx.transformPoint(topRight);

        //         bottomLeft.x = mx.tx;
        //         bottomLeft.y = mx.ty + rect.height;
        //         bottomLeft = mx.transformPoint(bottomLeft);

        //         bottomRight.x = mx.tx + rect.width;
        //         bottomRight.y = mx.ty + rect.height;
        //         bottomRight = mx.transformPoint(bottomRight);
        //     //}

        //     //индексы точек для этого тайла {
        //         idx = Std.int(v / 2);

        //         this._idx[ i++ ] = idx;
        //         this._idx[ i++ ] = idx + 1;
        //         this._idx[ i++ ] = idx + 2;

        //         this._idx[ i++ ] = idx + 1;
        //         this._idx[ i++ ] = idx + 2;
        //         this._idx[ i++ ] = idx + 3;
        //     //}

        //     //Вершины треугольников {
        //         //0
        //         this._uv[ u++ ] = (rect.left + 2) / this._bmp.width;
        //         this._uv[ u++ ] = (rect.top + 2) / this._bmp.height;
        //         this._vtx[ v++ ] = topLeft.x;
        //         this._vtx[ v++ ] = topLeft.y;
        //         //1
        //         this._uv[ u++ ] = rect.right / this._bmp.width;
        //         this._uv[ u++ ] = (rect.top + 2) / this._bmp.height;
        //         this._vtx[ v++ ] = topRight.x + topLeft.x;
        //         this._vtx[ v++ ] = topRight.y + topLeft.y;
        //         //2
        //         this._uv[ u++ ] = (rect.left + 2) / this._bmp.width;
        //         this._uv[ u++ ] = rect.bottom / this._bmp.height;
        //         this._vtx[ v++ ] = bottomLeft.x + topLeft.x;
        //         this._vtx[ v++ ] = bottomLeft.y + topLeft.y;
        //         //3
        //         this._uv[ u++ ] = rect.right / this._bmp.width;
        //         this._uv[ u++ ] = rect.bottom / this._bmp.height;
        //         this._vtx[ v++ ] = bottomRight.x + topLeft.x;
        //         this._vtx[ v++ ] = bottomRight.y + topLeft.y;
        //     //}
        // }//while(i)

        // //если массивы uv, vtx, idx с прошлого кадра были больше, чем с этого, то нужно отрезать лишнее{
        //     var cTiles : Int = Std.int(d / TsObject.DRAWDATA_NUM_IDX);

        //     if( this._uv.length / 8 >  cTiles){
        //         this._uv.splice(cTiles * 8, this._uv.length - cTiles * 8);
        //     }

        //     if( this._vtx.length / 8 >  cTiles){
        //         this._vtx.splice(cTiles * 8, this._vtx.length - cTiles * 8);
        //     }

        //     if( this._idx.length / 6 >  cTiles){
        //         this._idx.splice(cTiles * 6, this._idx.length - cTiles * 6);
        //     }
        // //}

        // graphics.clear();
        // graphics.beginBitmapFill(this._bmp, null, true, smooth);
        // graphics.drawTriangles(this._vtx, this._idx, this._uv);
        // graphics.endFill();

    }//function drawTiles()
#end

}//class SxTilesheet

