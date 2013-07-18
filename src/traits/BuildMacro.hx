package traits;

import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;


/**
* Yep, build macro
*
*/
@:access(traits.Trait)
class BuildMacro {


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Build traits / add trait fields to classes
    *
    */
    @:noCompletion macro static public function build() : Array<Field> {
        var pos    = Context.currentPos();
        var cls    = Context.getLocalClass().get();
        var fields = Context.getBuildFields();

        //trait
        if( cls.isInterface ){
            fields = Trait._processTrait(cls, fields);

        //trait descendant
        }else{

            //to prevent processing one class several times
            if( Trait._processed.exists(Trait.classpath(cls)) ){
                return fields;
            }
            Trait._processed.set(Trait.classpath(cls), true);

            fields = Trait._processDescendant(cls, cls.interfaces, fields);
        }

        return fields;
    }//function build()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class BuildMacro