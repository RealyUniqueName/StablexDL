package com.example;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import nme.text.TextField;
import ru.stablex.sxdl.SxStage;

/*******************************************************************************
*
*   Use `noscale` conditional compilation flag to disable scaling bannies
*
*******************************************************************************/

/**
* StablexDL test
*
*/
class Main extends nme.display.Sprite {

    //sxStage instance
    static public var sxStage : SxStage;
    //bunny counter
    static public var cnt : TextField;


    /**
    * Entry point
    *
    */
    static public function main () : Void {
        //counters
        cnt   = new TextField();
        cnt.x = Lib.current.stage.stageWidth / 2;
        cnt.mouseEnabled = false;
        Lib.current.addChild(cnt);
        Lib.current.addChild(new nme.display.FPS());

        //create sxStage
        sxStage = new SxStage();
        // sxStage.smooth = true;

        //create tilesheet
        sxStage.addSprite("assets/bunny.png");
        sxStage.lockSprites();

        //initial bunnies
        addBunnies(1000);

        //render on every frame
        Lib.current.addEventListener(Event.ENTER_FRAME, function(e:Event){
            sxStage.render(Lib.current.graphics);
        });

        //add bunnies on clicks
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent){
            addBunnies(100);
        });
    }//function main()


    /**
    * Add bunnies to sxStage
    *
    */
    static public function addBunnies(amount:Int) : Void {
        for(i in 0...amount){
            // sxStage.addChild(new Bunny());
            var bunny = new Bunny();
            bunny.tile = sxStage.getTile("assets/bunny.png");
            sxStage.addChild(bunny);
        }

        cnt.text = Std.string( sxStage.numChildren );
    }//function addBunnies()


}//class Main