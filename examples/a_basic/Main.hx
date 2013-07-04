package;


/**
* Entry point
*
*/
class Main implements TDemo {


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Entry point
    *
    */
    static public function main () : Void {
        var m = new Main();
        //call method implemented in TDemo
        m.hello("world");
    }//function main()

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
    }//function new()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Main