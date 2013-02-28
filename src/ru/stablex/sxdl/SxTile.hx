package ru.stablex.sxdl;


/**
* Describes tile in tilesheet
*
*/
class SxTile {
    //tile id in tilesheet
    public var id (default,null) : Int = 0;
    //tile width
    public var width (default,null) : Float = 0;
    //tile height
    public var height (default,null) : Float = 0;
    //center point X
    public var spotX (default,null) : Float = 0;
    //center point Y
    public var spotY (default,null) : Float = 0;


    /**
    * Constructor
    *
    */
    public function new (id:Int, width:Float, height:Float, spotX:Float, spotY:Float) : Void {
        this.id     = id;
        this.width  = width;
        this.height = height;
        this.spotX  = spotX;
        this.spotY  = spotY;
    }//function new()

}//class SxTile