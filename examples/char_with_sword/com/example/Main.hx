package com.example;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;
import ru.stablex.sxdl.SxObject;
import ru.stablex.sxdl.SxStage;
import ru.stablex.sxdl.SxTilesheet;
import ru.stablex.sxdl.TweenObject;


/**
* StablexDL test
*
*/
class Main extends nme.display.Sprite {


    /**
    * Entry point
    *
    */
    static public function main () : Void {
        //create stage
        var stage2 : SxStage = new SxStage();
        stage2.smooth = true;

        stage2.addSprite("char", "assets/char.png");
        stage2.addSprite("assets/sword.png", null, 1, -24.5, 117);
        stage2.lockSprites();

        //rotating char with sword {
            var char : TweenObject = new TweenObject();
            char.tile = stage2.getTile("char");
            char.x    = 200;
            char.y    = 300;

            var sword : SxObject = new SxObject();
            sword.tile = stage2.getTile("assets/sword.png");

            char.addChild(sword);
            stage2.addChild(char);

            char.tween(10, {rotation:360});
        //}

        //running char rotating sword{
            var char : TweenObject = new TweenObject();
            char.tile = stage2.getTile("char");
            char.x    = 500;
            char.y    = 300;

            var sword : TweenObject = new TweenObject();
            sword.tile = stage2.getTile("assets/sword.png");

            char.addChild(sword);
            stage2.addChild(char);

            var forward  : Void->Void = null;
            var backward : Void->Void = null;
            forward = function(){
                char.tween(0.5, {scaleX:1});
                char.tween(3, {x:char.x + 100}).onComplete(backward);
            }
            backward = function(){
                char.tween(0.5, {scaleX:-1});
                char.tween(3, {x:char.x - 100}).onComplete(forward);
            }

            forward();
            sword.tween(10, {rotation:360 * 10});
        //}

        Lib.current.addEventListener(Event.ENTER_FRAME, function(e:Event){
            stage2.render(Lib.current.graphics);
        });
    }//function main()


}//class Main