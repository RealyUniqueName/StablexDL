package ru.stablex.sxdl;

import nme.display.Graphics;
import nme.display.Tilesheet;


/**
* Stage object. Handles rendering
*
*/
class SxStage extends SxObject{

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
    private var _tsBuilder : SxTsBuilder;


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
        this._tsBuilder       = new SxTsBuilder();
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

        this.updateDisplayList();

        gr.clear();
        this.tilesheet.drawTiles(gr, this.tileData, this.smooth, Tilesheet.TILE_TRANS_2x2);
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

                tileDataIdx = obj.update(tileDataIdx);
                obj.dirty   = false;

            //object didn't change and has a tile
            }else if( obj.tile != null ) {
                tileDataIdx += 7;
            }
        }//while()

        if( tileDataIdx <= this.tileData.length ){
            this.tileData.splice(tileDataIdx, this.tileData.length - tileDataIdx + 1);
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
    * Build tilesheet. You can't add any new sprites after this method was invoked.
    *
    */
    public function lockSprites () : Void {
        this._tilesheet = this._tsBuilder.getTilesheet();
        this._tsBuilder  = null;
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

        return this.tilesheet.tiles.get(name);
    }//function getTile()


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