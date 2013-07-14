package;

import traits.ITrait ;



/**
* Demo trait
*
*/
interface TDemo extends ITrait {


    /**
    * Greetings
    *
    */
    override public function hello (name:String) : Void {
        super.hello("super");
        trace("Hello, " + name + "!");
    }//function hello()

}//interface TDemo