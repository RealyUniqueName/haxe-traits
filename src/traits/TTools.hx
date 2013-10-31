package traits;

#if macro

import haxe.macro.Expr;


/**
* Traits related tools
*
*/
class TTools {


    /**
    * Get fields from src to dst. Field will be added only if dst does not have any fields with such name.
    *
    */
    static public function getUniqueFields (src:Array<Field>, dst:Array<Field>) : Array<Field> {
        var has : Bool = false;
        var add : Array<Field> = [];
        if( src == null || dst == null ) return add;

        for(field in src){
            for(f in dst){
                if( f.name == field.name ) {
                    has = true;
                    break;
                }
            }

            if( !has ) {
                add.push(field);
            }
        }

        return add;
    }//function getUniqueFields()


}//class TTools


#end