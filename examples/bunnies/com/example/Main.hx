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

    //stage instance
    static public var stage2 : SxStage;
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

        //create stage
        stage2 = new SxStage();
        // stage.smooth = true;

        //create tilesheet
        stage2.addSprite("assets/bunny.png");
        stage2.lockSprites();

        //initial bunnies
        addBunnies(100);

        //render on every frame
        Lib.current.addEventListener(Event.ENTER_FRAME, function(e:Event){
            stage2.render(Lib.current.graphics);
        });

        //add bunnies on clicks
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent){
            addBunnies(100);
        });
    }//function main()


    /**
    * Add bunnies to stage
    *
    */
    static public function addBunnies(amount:Int) : Void {
        for(i in 0...amount){
            // stage.addChild(new Bunny());
            var bunny = new Bunny();
            bunny.tile = stage2.getTile("assets/bunny.png");
            stage2.addChild(bunny);
        }

        cnt.text = Std.string( stage2.numChildren );
    }//function addBunnies()


}//class Main