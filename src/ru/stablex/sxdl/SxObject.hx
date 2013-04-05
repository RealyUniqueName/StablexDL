package ru.stablex.sxdl;

import nme.events.EventDispatcher;
import nme.geom.Matrix;
import nme.errors.ArgumentError;
import nme.errors.RangeError;
import nme.geom.Point;


/**
* Base DisplayObject class.
* Also manages registered eventListeners.
*/
class SxObject extends EventDispatcher{
    static private inline var EXCEPTION_NOT_CHILD = 'Object does not contain this child';
    static private inline var EXCEPTION_RANGE_ERR = 'Index out of range';
    static public inline var DEG_TO_RAD = Math.PI / 180;

    //x coordinate
    public var x (get_x,set_x) : Float;
    private var _x : Float = 0;
    //y coordinate
    public var y (get_y,set_y) : Float;
    private var _y : Float = 0;
    //x scale
    public var scaleX (get_scaleX,set_scaleX) : Float;
    private var _scaleX : Float = 1;
    //y scale
    public var scaleY (get_scaleY,set_scaleY) : Float;
    private var _scaleY : Float = 1;
    //rotation (degrees clockwise)
    public var rotation (get_rotation,set_rotation) : Float;
    private var _rotation : Float = 0;
    //object's width
    public var width (get_width,set_width) : Float;
    //object's height
    public var height (get_height,set_height) : Float;
    //object's parent
    public var parent (default,null) : SxObject;
    //stage object
    public var stage (default,set_stage) : SxStage;
    //children amount
    public var numChildren (get_numChildren,never) : Int;
    //object's children
    private var _children : Array<SxObject>;
    //index of object in parent's display list
    private var _childIdx (default,null) : Int;
    //tile data
    public var tile (default,set_tile) : SxTile;
    //registered event listeners
    private var _listeners : Hash<List<Dynamic->Void>>;
    //index of first element in _tileData for this object
    public var _tileDataIdx : Int;
    //combined matrix to calculate real x, y, rotation etc.
    private var _mx : Matrix;
    //if this object needs `.update()`
    public var dirty : Bool = false;
    //object's name
    public var name : String;
    //ast it says
    public var displayListSize (default,set_displayListSize) : Int = 1;
    //index of this object in displayList of stage
    public var displayListIdx (get_displayListIdx,set_displayListIdx) : Int;
    private var _displayListIdx : Int = 0;
    //index of last [grand-[grand-...]]-child in displayList of stage
    public var displayListLastIdx : Int = -1;



    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();
        this._mx = new Matrix();
    }//function new()


    /**
    * Equal to <type>nme.display.Sprite</type>.addEventListener except this ignores `useCapture` and does not support weak references.
    *
    */
    override public function addEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Void{
        //if listeners list is not created
        if( this._listeners == null ){
            this._listeners = new Hash();
        }

        var listeners : List<Dynamic->Void> = this._listeners.get(type);

        //if we don't have list of listeners for this event, create one
        if( listeners == null ){
            listeners = new List();
            listeners.add(listener);
            this._listeners.set(type, listeners);

        //add listener to the list
        }else{
            listeners.add(listener);
        }

        super.addEventListener(type, listener, false, priority, useWeakReference);
    }//function addEventListener()


    /**
    * Add event listener only if this listener is still not added to this object
    * Ignores `useCapture` and `useWeakReference`
    *
    * @return whether listener was added
    */
    public inline function addUniqueListener (type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) : Bool{
        if( this.hasListener(type, listener) ){
            return false;
        }else{
            this.addEventListener(type, listener, useCapture, priority, useWeakReference);
            return true;
        }
    }//function addEventListener()


    /**
    * Equal to <type>nme.display.Sprite</type>.removeEventListener except this ignores `useCapture`
    *
    */
    override public function removeEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false) : Void{
        //remove listener from the list of registered listeners
        if( this._listeners != null ){
            if( this._listeners.exists(type) ) this._listeners.get(type).remove(listener);
        }

        super.removeEventListener(type, listener, false);
    }//function removeEventListener()


    /**
    * Removes all listeners registered for this event
    *
    */
    public function clearEvent (type:String) : Void {
        if( this._listeners != null ){
            var listeners : List<Dynamic->Void> = this._listeners.get(type);
            if( listeners != null ){
                while( listeners.length > 0 ){
                    this.removeEventListener(type, listeners.first());
                }
            }
        }
    }//function clearEvent()


    /**
    * Indicates whether this object has this listener registered for specified event type
    *
    */
    public function hasListener(event:String, listener:Dynamic->Void) : Bool {
        if( this._listeners == null ) return false;

        var lst : List<Dynamic->Void> = this._listeners.get(event);
        if( lst == null ) return false;

        for(l in lst){
            if( l == listener ) return true;
        }

        return false;
    }//function hasListener()


    /**
    * Free object. Removes all registered eventListeners and children. Also removes itself from parent's display list.
    * If `recursive` is true (by default), tries to call .free(true) for each child
    */
    public function free (recursive:Bool = true) : Void{
        //clear listeners
        if( this._listeners != null ){
            for(event in this._listeners.keys()){
                var listeners : List<Dynamic->Void> = this._listeners.get(event);
                while( !listeners.isEmpty() ){
                    this.removeEventListener(event, listeners.first());
                }
            }
        }

        //release children
        this.freeChildren(recursive);

        //removing from parent's display list
        if( this.parent != null ){
            this.parent.removeChild(this);
        }
    }//function free()


    /**
    * Removes children. If `recursive` = true (default) tries to call .free(true) on children
    */
    public function freeChildren(recursive:Bool = true) : Void {
        var child : SxObject;
        while( this.numChildren > 0 ){
            child = this.removeChildAt(0);

            if( recursive && Std.is(child, SxObject) ){
                cast(child, SxObject).free(true);
            }
        }
    }//function freeChildren()


/*******************************************************************************
*   Display object methods
*******************************************************************************/

    /**
    * Create array for _children, if still not created
    *
    */
    private inline function _ensureChilrdenArray () : Void {
        if( this._children == null ) this._children = [];
    }//function _ensureChilrdenArray()


    /**
    * Fix indexes for children in specified range
    *
    */
    private inline function _reindexChildren (start:Int, stop:Int, displayListIdx:Int = -1) : Void {
        //no need to set displayListIdx
        if( displayListIdx < 0 ){
            for(i in start...stop + 1){
                this._children[i]._childIdx = i;
            }

        //also set displayListIdx
        }else{
            for(i in start...stop + 1){
                this._children[i]._childIdx = i;
                this._children[i].displayListIdx = displayListIdx;
                displayListIdx += this._children[i].displayListSize;
            }

        }
    }//function _reindexChildren()


    /**
    * Get child index in display list
    *
    */
    public function getChildIndex (child:SxObject) : Int {
        if( child.parent != this ){
            throw new ArgumentError(EXCEPTION_NOT_CHILD);
        }

        return child._childIdx;
    }//function getChildIndex()


    /**
    * Get child at specified index
    *
    */
    public function getChildAt (idx:Int) : SxObject {
        this._ensureChilrdenArray();

        if( this._children.length <= idx || idx < 0 ){
            throw new RangeError(EXCEPTION_RANGE_ERR);
        }

        return this._children[idx];
    }//function getChildAt()


    /**
    * Find child with specified name
    *
    */
    public function getChildByName (name:String) : Null<SxObject> {
        this._ensureChilrdenArray();

        for(child in this._children){
            if( child.name == name ){
                return child;
            }
        }

        return null;
    }//function getChildByName()


    /**
    * Add child to display list
    *
    */
    public function addChild (child:SxObject) : SxObject {
        this._ensureChilrdenArray();

        if( child.parent != null ){
            child.parent.removeChild(child);
        }

        child.parent    = this;
        child._childIdx = this._children.push(child) - 1;
        child.dirty     = true;

        //keep display list order{
            if( this.stage != null ){
                child.displayListIdx = this.displayListIdx + this.displayListSize;
            }
            child.stage = this.stage;

            if( child.stage != null ){
                child.stage.updateDisplayListIdx(child.displayListIdx + child.displayListSize, child.stage.displayList.length - 1);
            }

            this.displayListSize += child.displayListSize;
        //}

        return child;
    }//function addChild()


    /**
    * Add child at specified index
    *
    */
    public function addChildAt (child:SxObject, idx:Int) : SxObject {
        this._ensureChilrdenArray();

        if( this._children.length < idx || idx < 0 ){
            throw new RangeError(EXCEPTION_RANGE_ERR);
        }

        if( child.parent != null ){
            child.parent.removeChild(child);
        }

        this._children.insert(idx, child);
        child.parent    = this;
        child._childIdx = idx;
        child.dirty     = true;

        this._reindexChildren(idx, this._children.length - 1);

        //keep display list order{
            if( this.stage != null ){
                child.displayListIdx = (idx == 0 ? this.displayListIdx + (this == this.stage ? 0 : 1) : this._children[idx - 1].displayListIdx + this._children[idx - 1].displayListSize);
            }
            child.stage = this.stage;

            if( child.stage != null ){
                child.stage.updateDisplayListIdx(child.displayListIdx + child.displayListSize, child.stage.displayList.length - 1);
            }

            this.displayListSize += child.displayListSize;
        //}

        return child;
    }//function addChildAt()


    /**
    * Remove child from display list
    *
    */
    public function removeChild (child:SxObject) : SxObject {
        this._ensureChilrdenArray();

        if( this._children[ child._childIdx ] != child ){
            throw new ArgumentError(EXCEPTION_NOT_CHILD);
        }

        this._children.splice(child._childIdx, 1);
        child.parent = null;

        if( child.stage != null ){
            child.stage.removeFromDisplayList(child);
            child.stage  = null;
        }

        this._reindexChildren(child._childIdx, this._children.length - 1);

        this.displayListSize -= child.displayListSize;

        return child;
    }//function removeChild()


    /**
    * Remove child at specified index
    *
    */
    public function removeChildAt (idx:Int) : SxObject {
        return this.removeChild( this.getChildAt(idx) );
    }//function removeChildAt()


    /**
    * Determines whether the specified display object is a child of the SxObject instance or the instance itself
    *
    */
    public function contains (child:SxObject) : Bool{
        if( child.parent == this || child == this ){
            return true;

        }else{
            this._ensureChilrdenArray();

            for(i in 0...this._children.length){
                if( this._children[i].contains(child) ){
                    return true;
                }
            }

            return false;
        }
    }//function contains()


    /**
    * Move child to specified index
    *
    */
    public function setChildIndex (child:SxObject, idx:Int) : Void {
        this.removeChild(child);
        if( idx > child._childIdx ){
            this.addChildAt(child, idx - 1);
        }else{
            this.addChildAt(child, idx);
        }

        // this._ensureChilrdenArray();

        // if( this._children.length <= idx || idx < 0 ){
        //     throw new RangeError(EXCEPTION_RANGE_ERR);
        // }
        // if( child.parent != this ){
        //     throw new ArgumentError(EXCEPTION_NOT_CHILD);
        // }

        // var from: Int = 0;
        // var to  : Int = 0;

        // //move to beginning
        // if( idx < child._childIdx ){
        //     this._children.splice(child._childIdx, 1);
        //     this._children.insert(idx, child);

        //     from = idx;
        //     to   = child._childIdx;
        // //move to end
        // }else{
        //     this._children.splice(child._childIdx, 1);
        //     this._children.insert(idx - 1, child);

        //     from = child._childIdx;
        //     to   = idx;
        // }

        // //adjust indexes
        // this._reindexChildren(from, to);

        // //keep display list order
        // if( this.stage != null ){
        //     this.stage.displayList.splice(child.displayListIdx, child.displayListSize);
        //     var updateIdxTo : Int = child.displayListIdx + child.displayListSize;

        //     child.displayListIdx = (idx == 0 ? this.displayListIdx + (this == this.stage ? 0 : 1) : this._children[idx - 1].displayListIdx + this._children[idx - 1].displayListSize);

        //     child.stage = this.stage;

        //     child.stage.updateDisplayListIdx(child.displayListIdx + child.displayListSize, updateIdxTo);
        // }
    }//function setChildIndex()


    /**
    * Swaps the z-order (front-to-back order) of the two specified child objects.
    *
    */
    public function swapChildren (child1:SxObject, child2:SxObject) : Void {
        this._ensureChilrdenArray();

        if( child1.parent != this || child2.parent != this ){
            throw new ArgumentError(EXCEPTION_NOT_CHILD);
        }

        this._children[ child1._childIdx ] = child2;
        this._children[ child2._childIdx ] = child1;

        var tmp: Int     = child1._childIdx;
        child1._childIdx = child2._childIdx;
        child2._childIdx = tmp;

        //keep display list order
        if( this.stage != null ){
            var idx1 : Int = child1.displayListIdx;
            var idx2 : Int = child2.displayListIdx;

            if( idx1 > idx2 ){
                var tmp : SxObject = child2;
                child2 = child1;
                child1 = tmp;
            }

            this.stage.displayList.splice(idx2, child2.displayListSize);

            child1.displayListIdx = idx2;
            child1.stage           = this.stage;

            this.stage.displayList.splice(idx1, child1.displayListSize);
            child2.displayListIdx = idx1;
            child2.stage           = this.stage;

            this.stage.updateDisplayListIdx(idx1, idx2 + child1.displayListSize - 1);
        }
    }//function swapChildren()


    /**
    * Swaps the z-order (front-to-back order) of the child objects at the two specified index positions in the child list.
    *
    */
    public function swapChildrenAt (idx1:Int, idx2:Int) : Void {
        this.swapChildren(this.getChildAt(idx1), this.getChildAt(idx2));

        // this._ensureChilrdenArray();

        // if( idx1 < 0 || idx1 >= this._children.length || idx2 < 0 || idx2 >= this._children.length ){
        //     throw new RangeError(EXCEPTION_RANGE_ERR);
        // }

        // var tmp : SxObject     = this._children[ idx1 ];
        // this._children[ idx1 ] = this._children[ idx2 ];
        // this._children[ idx2 ] = tmp;

        // this._children[ idx1 ]._childIdx = idx1;
        // this._children[ idx2 ]._childIdx = idx2;
    }//function swapChildrenAt()


    // /**
    // * Converts the point object from the SxStage (global) coordinates to the display object's (local) coordinates.
    // *
    // */
    // public function globalToLocal (p:Point) : Point {
    //     return p;
    // }//function globalToLocal()


    // /**
    // * Converts the point object from the display object's (local) coordinates to the Stage (global) coordinates.
    // *
    // */
    // public function localToGlobal (p:Point) : Point {
    //     return p;
    // }//function localToGlobal()


    /**
    * Update object's tileData
    * @private
    */
    public function update (tileDataIdx:Int) : Int {

        #if nostransform
            this._mx.tx = this._x + this.parent._x;
            this._mx.ty = this._y + this.parent._y;
        #else
            this._mx.identity();
            this._mx.scale(this._scaleX, this._scaleY);
            this._mx.rotate(this._rotation * DEG_TO_RAD);
            this._mx.translate(this._x, this._y);
            this._mx.concat(this.parent._mx);
        #end

        if( this.tile != null ){
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.tx;
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.ty;
            this.stage.tileData[ tileDataIdx ++ ] = this.tile.id;

            #if !notransform
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.a;
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.c;
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.b;
            this.stage.tileData[ tileDataIdx ++ ] = this._mx.d;
            #end
        }

        return tileDataIdx;
    }//function update()


    /**
    * Calculate global coordinates of local point
    *
    */
    public function localToGlobal (p:Point) : Point {
        //if matrix is not calculated
        if( this.dirty ){
            var mx : Matrix = new Matrix();
            var parent : SxObject = this;
            while( parent != null && !Std.is(p, SxStage) ){
                mx.identity();
                #if !notransform
                    mx.scale(parent._scaleX, parent._scaleY);
                    mx.rotate(parent._rotation * DEG_TO_RAD);
                #end
                mx.translate(parent._x, parent._y);
                p = mx.transformPoint(p);
                parent = parent.parent;
            }

            return p;

        //if matrix is already calculated
        }else{
            return this._mx.transformPoint(p);
        }
    }//function localToGlobal()

/*******************************************************************************
*   GETTERS / SETTERS
*******************************************************************************/

    /**
    * Getter `numChildren`.
    *
    */
    private inline function get_numChildren () : Int {
        return (this._children == null ? 0 : this._children.length);
    }//function get_numChildren


    /**
    * Getter `x`.
    *
    */
    private inline function get_x () : Float {
        return this._x;
    }//function get_x


    /**
    * Setter `x`.
    *
    */
    private inline function set_x (x:Float) : Float {
        this.dirty = true;
        return this._x = x;
    }//function set_x


    /**
    * Getter `y`.
    *
    */
    private inline function get_y () : Float {
        return this._y;
    }//function get_y


    /**
    * Setter `y`.
    *
    */
    private inline function set_y (y:Float) : Float {
        this.dirty = true;
        return this._y = y;
    }//function set_y


    /**
    * Getter `scaleX`.
    *
    */
    private inline function get_scaleX () : Float {
        return this._scaleX;
    }//function get_scaleX


    /**
    * Setter `scaleX`.
    *
    */
    private inline function set_scaleX (scaleX:Float) : Float {
        this.dirty = true;
        return this._scaleX = scaleX;
    }//function set_scaleX


    /**
    * Getter `scaleY`.
    *
    */
    private inline function get_scaleY () : Float {
        return this._scaleY;
    }//function get_scaleY


    /**
    * Setter `scaleY`.
    *
    */
    private inline function set_scaleY (scaleY:Float) : Float {
        this.dirty = true;
        return this._scaleY = scaleY;
    }//function set_scaleY


    /**
    * Getter `rotation`.
    *
    */
    private inline function get_rotation () : Float {
        return this._rotation;
    }//function get_rotation


    /**
    * Setter `rotation`.
    *
    */
    private inline function set_rotation (rotation:Float) : Float {
        this.dirty = true;
        return this._rotation = rotation;
    }//function set_rotation


    /**
    * Setter `stage`.
    *
    */
    private function set_stage (stage:SxStage) : SxStage {
        if( stage != null ){
            stage.displayList.insert(this.displayListIdx, this);
        }

        if( this._children != null ){
            for(i in 0...this._children.length){
                this._children[i].stage = stage;
            }
        }

        return this.stage = stage;
    }//function set_stage


    /**
    * Setter `tile`.
    *
    */
    private inline function set_tile (tile:SxTile) : SxTile {
        this.dirty = true;
        return this.tile = tile;
    }//function set_tile


    /**
    * Getter `displayListIdx`.
    *
    */
    private inline function get_displayListIdx () : Int {
        return this._displayListIdx;
    }//function get_displayListIdx


    /**
    * Setter `displayListIdx`.
    *
    */
    private function set_displayListIdx (displayListIdx:Int) : Int {
        if( this._children != null ){
            var total : Int = 1;
            for(i in 0...this._children.length){
                this._children[i].displayListIdx = displayListIdx + total;
                total += this._children[i].displayListSize;
            }
        }

        this.dirty = true;
        return this._displayListIdx = displayListIdx;
    }//function set_displayListIdx


    /**
    * Setter `displayListSize`.
    *
    */
    private function set_displayListSize (displayListSize:Int) : Int {
        if( this.parent != null ){
            this.parent.displayListSize += displayListSize - this.displayListSize;
        }
        return this.displayListSize = displayListSize;
    }//function set_displayListSize


    /**
    * Getter `width`.
    *
    */
    private inline function get_width () : Float {
        return (this.tile == null ? 0 : this.tile.width * this.scaleX);
    }//function get_width


    /**
    * Setter `width`.
    *
    */
    private inline function set_width (width:Float) : Float {
        if( this.tile != null ){
            this.scaleX = width / this.tile.width;
        }
        return width;
    }//function set_width


    /**
    * Getter `height`.
    *
    */
    private inline function get_height () : Float {
        return (this.tile == null ? 0 : this.tile.height * this.scaleY);
    }//function get_height


    /**
    * Setter `height`.
    *
    */
    private inline function set_height (height:Float) : Float {
        if( this.tile != null ){
            this.scaleY = height / this.tile.height;
        }
        return height;
    }//function set_height
}//class SxObject