package com.example;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.Lib;
import ru.stablex.sxdl.SxObject;
import ru.stablex.sxdl.SxStage;
import ru.stablex.sxdl.SxTile;
import ru.stablex.sxdl.SxTilesheet;
import ru.stablex.sxdl.TweenObject;


/**
* StablexDL test
*
*/
class Main extends nme.display.Sprite {

    static public var stage : SxStage;
    static public var tile : SxTile;


    /**
    * Entry point
    *
    */
    static public function main () : Void {
        //create stage
        stage = new SxStage();
        stage.smooth = true;

        stage.addSprite("char", "assets/char.png");
        stage.addSprite("assets/sword.png", null, 1, -24.5, 117);
        stage.lockSprites();

        //rotating char with sword {
            var char : TweenObject = new TweenObject();
            char.tile = stage.getTile("char");
            char.x    = 200;
            char.y    = 300;

            var sword : SxObject = new SxObject();
            sword.tile = stage.getTile("assets/sword.png");

            char.addChild(sword);
            stage.addChild(char);

            char.tween(10, {rotation:360});
        //}

        //running char rotating sword{
            var char : TweenObject = new TweenObject();
            char.tile = stage.getTile("char");
            char.x    = 500;
            char.y    = 300;

            var sword : TweenObject = new TweenObject();
            sword.tile = stage.getTile("assets/sword.png");

            char.addChild(sword);
            stage.addChild(char);

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
            stage.render(Lib.current.graphics);
        });
    }//function main()


}//class Main