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
    public function hello (name:String) : Void {
        trace("Hello, " + name + "!");
    }//function hello()

}//interface TDemo