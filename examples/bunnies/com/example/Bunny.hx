package com.example;

import ru.stablex.sxdl.SxObject;
import ru.stablex.sxdl.SxStage;


/**
* Bunny instance
*
*/
class Bunny extends SxObject{

    //velocities
    public var xVel : Float = 5;
    public var yVel : Float = 5;
    public var aVel : Float = 10;
    public var sVel : Float = 0.1;

/*******************************************************************************
*   STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*   INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new() : Void {
        super();

        this.xVel *= Math.random() * (Std.random(2) == 0 ? -1 : 1);
        this.yVel *= Math.random() * (Std.random(2) == 0 ? -1 : 1);
        this.aVel *= Math.random() * (Std.random(2) == 0 ? -1 : 1);
        this.sVel *= Math.random() * (Std.random(2) == 0 ? -1 : 1);

        this.x = 120;
        this.y = 160;
        this.rotation = 360 * Math.random();

        #if !noscale
        this.scaleX = this.scaleY = 0.2 + 0.8 * Math.random();
        #end
    }//function new()


    /**
    * This method is called once per frame if object changed during this frame.
    * We will change bunny's data, so this method will be called again on next frame, and so on.
    */
    override public function update(idx:Int) : Int {
        this.rotation += this.aVel;

        if( this.x > 640 || this.x < 0 ){
            this.xVel *= -1;
        }
        if( this.y > 480 || this.y < 0 ){
            this.yVel *= -1;
        }
        if( Math.abs(this.scaleX) > 1 ){
            this.sVel *= -1;
        }

        this.x += this.xVel;
        this.y += this.yVel;

        #if !noscale
        this.scaleX = this.scaleY += this.sVel;
        #end

        return super.update(idx);
    }//function update()



/*******************************************************************************
*   GETTERS / SETTERS
*******************************************************************************/

    // /**
    // * Setter stage
    // *
    // */
    // override private function set_stage(stage:SxStage) : SxStage {
    //     if( stage != null ){
    //         this.tile = stage.getTile("assets/buny.png");
    //     }
    //     return super.set_stage(stage);
    // }//function set_stage()

}//class Bunny