package com.example;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import nme.text.TextField;
import ru.stablex.sxdl.SxStage;
import ru.stablex.sxdl.SxObject;

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
        stage2.smooth = true;

        //create tilesheet
        stage2.addSprite("assets/bunny.png");
        stage2.lockSprites();

        //root object
        var root : SxObject = new SxObject();
        stage2.addChild(root);

        //initial bunnies
        addBunnies(300);

        //render on every frame
        Lib.current.addEventListener(Event.ENTER_FRAME, function(e:Event){
            stage2.render(Lib.current.graphics);
            root.rotation ++;
        });

        //add bunnies on clicks
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent){
            addBunnies(300);
        });
    }//function main()


    /**
    * Add bunnies to stage
    *
    */
    static public function addBunnies(amount:Int) : Void {
        // for(i in 0...amount){
        //     // stage.addChild(new Bunny());
        //     var bunny = new Bunny();
        //     bunny.tile = stage.getTile("assets/bunny.png");
        //     stage.addChild(bunny);
        // }
        var root = stage2.getChildAt(0);
        root.x = stage2.stageWidth / 2;
        root.y = stage2.stageHeight / 2;

        var tile = stage2.getTile("assets/bunny.png");

        var cells = Std.int(Math.sqrt(root.numChildren + amount));
        var x : Float = - cells / 2 * tile.width + 3;
        var y : Float = - cells / 2 * tile.height + 3;

        var i : Int = 0;
        var obj : SxObject;

        for(c in 0...cells){
            y = - cells / 2 * tile.height + 3;

            for(r in 0...cells){
                if( i < root.numChildren ){
                    obj = root.getChildAt(i);
                }else{
                    obj = new SxObject();
                    root.addChild(obj);
                    obj.tile = tile;
                }

                obj.x = x;
                obj.y = y;

                y += tile.height + 3;

                i++;
            }

            x += tile.width + 3;
        }

        cnt.text = Std.string( root.numChildren );
    }//function addBunnies()


}//class Main