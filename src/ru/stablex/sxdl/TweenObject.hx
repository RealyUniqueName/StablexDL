package ru.stablex.sxdl;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import com.eclecticdesignstudio.motion.easing.Quad;
import com.eclecticdesignstudio.motion.easing.Expo;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.easing.Quint;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.IEasing;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Quart;
import com.eclecticdesignstudio.motion.easing.Cubic;
import com.eclecticdesignstudio.motion.easing.Sine;


/**
* SxObject with easy access to Actuate.tween()
*
*/
class TweenObject extends SxObject{
    
    /**
    * Easy access to <type>com.eclecticdesignstudio.motion.Actuate</type>.tween for this object. Equals to <type>com.eclecticdesignstudio.motion.Actuate</type>.tween(this, ....).
    * Parameter `easing` should be like this: 'Quad.easeInOut' or 'Back.easeIn' etc. By default it is 'Linear.easeNone'
    *
    */
    public inline function tween (duration:Float, properties:Dynamic, easing:String = 'Linear.easeNone', overwrite:Bool = true, customActuator:Class<GenericActuator> = null) : IGenericActuator{
        var actuator : IGenericActuator;

        switch(easing){
            case 'Quad.easeInOut'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quad.easeInOut);
            case 'Quad.easeOut'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quad.easeOut);
            case 'Quad.easeIn'       : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quad.easeIn);
            case 'Expo.easeInOut'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Expo.easeInOut);
            case 'Expo.easeOut'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Expo.easeOut);
            case 'Expo.easeIn'       : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Expo.easeIn);
            case 'Bounce.easeInOut'  : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Bounce.easeInOut);
            case 'Bounce.easeOut'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Bounce.easeOut);
            case 'Bounce.easeIn'     : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Bounce.easeIn);
            case 'Quint.easeInOut'   : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quint.easeInOut);
            case 'Quint.easeOut'     : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quint.easeOut);
            case 'Quint.easeIn'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quint.easeIn);
            case 'Elastic.easeInOut' : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Elastic.easeInOut);
            case 'Elastic.easeOut'   : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Elastic.easeOut);
            case 'Elastic.easeIn'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Elastic.easeIn);
            case 'Back.easeInOut'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Back.easeInOut);
            case 'Back.easeOut'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Back.easeOut);
            case 'Back.easeIn'       : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Back.easeIn);
            case 'Quart.easeInOut'   : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quart.easeInOut);
            case 'Quart.easeOut'     : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quart.easeOut);
            case 'Quart.easeIn'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Quart.easeIn);
            case 'Cubic.easeInOut'   : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Cubic.easeInOut);
            case 'Cubic.easeOut'     : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Cubic.easeOut);
            case 'Cubic.easeIn'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Cubic.easeIn);
            case 'Sine.easeInOut'    : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Sine.easeInOut);
            case 'Sine.easeOut'      : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Sine.easeOut);
            case 'Sine.easeIn'       : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Sine.easeIn);

            case 'Linear.easeNone': actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Linear.easeNone);
            default               : actuator = Actuate.tween(this, duration, properties, overwrite, customActuator).ease(Linear.easeNone);
        }

        return actuator;
    }//function tween()


    /**
    * Calls <type>com.eclecticdesignstudio.motion.Actuate</type>.stop() for this object. By default `complete` and `sendEvent` equal to false
    *
    */
    public inline function tweenStop(properties:Dynamic = null, complete:Bool = false, sendEvent:Bool = false) : Void {
        Actuate.stop(this, properties, complete, sendEvent);
    }//function tweenStop()


    /**
    * Destroy object. Also call `.tweenStop()`
    *
    */
    override public function free (recursive:Bool = true) : Void {
        this.tweenStop();
        super.free(recursive);
    }//function free()
    
}//class TweenObject