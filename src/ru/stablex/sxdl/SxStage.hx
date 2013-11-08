package ru.stablex.sxdl;

import flash.display.Graphics;
import openfl.display.Tilesheet;
import flash.Lib;
#if (flash && !notransform)
import flash.geom.Point;
import flash.Vector;
import ru.stablex.sxdl.SxTile;
#end


/**
* Stage object. Handles rendering
*
*/
class SxStage extends SxObject{
    //amount of elements in stage.tileData per tile
    #if notransform
        static public inline var DPT = 3+1;
    #else
        static public inline var DPT = 7+1;
    #end

    //tilesheet to use for rendering
    public var tilesheet (get_tilesheet,never) : SxTilesheet;
    private var _tilesheet : SxTilesheet;
    //use smoothing?
    public var smooth : Bool = false;
    //draw data of display list
    public var tileData : Array<Float>;
    //display list
    public var displayList : Array<SxObject>;
    //tilesheet builder
    public var _tsBuilder : SxTsBuilder;
    //by default = Lib.current.stage.stageWidth. This affects only flash with `notransform` flag
    public var stageWidth : Int;
    //by default = Lib.current.stage.stageHeight. This affects only flash with `notransform` flag
    public var stageHeight : Int;

    #if (flash && !notransform)
        public var vtx : Vector<Float>;
        public var idx : Vector<Int>;
        public var uv  : Vector<Float>;

        public var topLeft     : Point;
        public var topRight    : Point;
        public var bottomLeft  : Point;
        public var bottomRight : Point;
    #end

    /**
    * Threads test
    */
    #if (cpp && thread)
        public var deque : cpp.vm.Deque<Bool>;

        /**
        * Threading test
        *
        */
        public function thread() : Void {
            while( this.deque.pop(true) ){
                this.updateDisplayList();
            }
        }//function thread()
    #end

    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();
        this.tileData        = [];
        this.displayList     = [];
        this.displayListSize = 0;
        this.stage           = this;
        this._tsBuilder      = new SxTsBuilder();
        this.stageWidth      = Std.int(Lib.current.stage.stageWidth);
        this.stageHeight     = Std.int(Lib.current.stage.stageHeight);
        #if (flash && !notransform)
            this.uv    = new Vector();
            this.idx   = new Vector();
            this.vtx   = new Vector();

            this.topLeft     = new Point(0, 0);
            this.topRight    = new Point(0, 0);
            this.bottomLeft  = new Point(0, 0);
            this.bottomRight = new Point(0, 0);
        #end

        #if (cpp && thread)
            this.deque = new cpp.vm.Deque();
            cpp.vm.Thread.create(this.thread);
        #end
    }//function new()


    /**
    * Renders frame
    *
    */
    public function render (gr:Graphics) : Void {
        #if debug
            if( this._tilesheet == null ){
                throw "Sprite creation is not finished. stage.lockSprites() was not called.";
            }
        #end

        #if !(cpp && thread)
            this.updateDisplayList();
        #else
            this.deque.push(true);
        #end

        gr.clear();
        #if flash
            #if notransform
            this.tilesheet.drawTiles(gr, this.tileData, this);
            #else
            this.tilesheet.drawTiles(gr, this.tileData, this.vtx, this.idx, this.uv, this.smooth);
            #end
        #else
            this.tilesheet.drawTiles(gr, this.tileData, this.smooth, Tilesheet.TILE_ALPHA #if !notransform | Tilesheet.TILE_TRANS_2x2 #end);

        #end

    }//function render()


    /**
    * Update tileData array
    * @private
    */
    public function updateTileData (obj:SxObject, forceUpdate:Bool = false, tileDataIdx:Int = 0) : Int {
        if( obj.dirty || forceUpdate ){
            tileDataIdx = obj.update(tileDataIdx);
            forceUpdate = true;
        }

        if( obj._children != null ){
            for(i in 0...obj._children.length){
                tileDataIdx = this.updateTileData(obj._children[i], forceUpdate, tileDataIdx);
            }
        }

        return tileDataIdx;
    }//function updateTileData()


    /**
    * Update tileData
    *
    */
    public function updateDisplayList () : Void {
        var tileDataIdx : Int = 0;
        var dirtyLength : Int = 0;
        var i           : Int = 0;
        var obj         : SxObject;

        while( this.displayList.length > i ){
            obj = this.displayList[i];
            i++;

            //object changed
            if( dirtyLength > 0 || obj.dirty ){
                if( dirtyLength <= 0 ){
                    dirtyLength = obj.displayListSize;
                }
                dirtyLength --;

                obj.dirty   = false;
                tileDataIdx = obj.update(tileDataIdx);

            //object didn't change and has a tile
            }else if( obj.tile != null ) {
                tileDataIdx += SxStage.DPT;
            }
        }//while()

        if( tileDataIdx <= this.tileData.length ){
            this.tileData.splice(tileDataIdx, this.tileData.length - tileDataIdx + 1);
            #if (flash && !notransform)
                this.vtx.splice(Std.int(tileDataIdx / 7) * 8, this.vtx.length - Std.int(tileDataIdx / 7) * 8);
                this.idx.splice(Std.int(tileDataIdx / 7) * 6, this.vtx.length - Std.int(tileDataIdx / 7) * 6);
                this.uv.splice(Std.int(tileDataIdx / 7) * 8, this.vtx.length - Std.int(tileDataIdx / 7) * 8);
            #end
        }

    }//function updateDisplayList()


    /**
    * Remove object from stage
    *
    */
    public inline function removeFromDisplayList (obj:SxObject) : Void {
        this.displayList.splice(obj.displayListIdx, obj.displayListSize);

        for(i in obj.displayListIdx...this.displayList.length){
            this.displayList[i]._displayListIdx = i;
            this.displayList[i].dirty = true;
        }
    }//function removeFromDisplayList()


    /**
    * Update `.displayListIdx` for specified range of display list
    *
    */
    public inline function updateDisplayListIdx (start:Int, stop:Int) : Void {
        for(i in start...(stop+1)){
            this.displayList[i]._displayListIdx = i;
            this.displayList[i].dirty = true;
        }
    }//function updateDisplayListIdx()


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
        if( this._tilesheet != null ){
            throw "Can't add new sprites after stage.lockSprites() was called.";
        }

        this._tsBuilder.addSprite(name, bmp, scale, spotX, spotY, clipAlpha, sourceSizeForSpot, smooth);
    }//function addSprite();


    /**
    * Description
    *
    */
    public function addSequence (name:String, bmp:Dynamic, frameWidth:Int, frameHeight:Int, scale:Float = 1, spotX:Null<Float> = null, spotY:Null<Float> = null, smooth:Bool = true) : Void {
        if( this._tilesheet != null ){
            throw "Can't add new sprites after stage.lockSprites() was called.";
        }

        this._tsBuilder.addSequence(name, bmp, frameWidth, frameHeight, scale, spotX, spotY, smooth);
    }//function addSequence()


    /**
    * Build tilesheet. You can't add any new sprites after this method was invoked.
    *
    */
    public function lockSprites () : Void {
        this._tilesheet = this._tsBuilder.getTilesheet();
        #if !flash
            this._tsBuilder  = null;
        #end
    }//function lockSprites()


    /**
    * Get tile by name
    *
    */
    public inline function getTile (name:String) : SxTile {
        #if debug
            if( this._tilesheet == null ){
                throw "Sprite creation is not finished. stage.lockSprites() was not called.";
            }
        #end

        return this.tilesheet._sxtiles.get(name);
    }//function getTile()


    /**
    * Get sequence of tiles
    *
    */
    public function getSequence (name:String) : Null<Array<SxTile>> {
        var tiles = this.tilesheet.sequences.get(name);
        return (tiles == null ? null : tiles.copy());
    }//function getSequence()

/*******************************************************************************
*   GETTERS / SETTERS
*******************************************************************************/

    /**
    * Setter `stage`.
    *
    */
    override  private function set_stage (stage:SxStage) : SxStage {
        return this.stage = stage;
    }//function set_stage


    /**
    * Getter `tilesheet`.
    *
    */
    private inline function get_tilesheet () : SxTilesheet {
        #if debug
            if( this._tilesheet == null ){
                throw "Sprite creation is not finished. Use stage.lockSprites().";
            }
        #end
        return this._tilesheet;
    }//function get_tilesheet
}//class SxStage