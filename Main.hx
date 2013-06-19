package;

import people.Jack;



/**
* Entry point
*
*/
class Main {


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Entry point
    *
    */
    static public function main () : Void {
        var p = new Jack();
        //act as Jack
        p.say();
        //act as a postman
        p.send("Hello, world");
        //act as a chef
        p.cook("bread");

        trace(Jack.INHERITED_STATIC_FIELD + " acquired as people.Jack.INHERITED_STATIC_FIELD");
        Jack.inheritedStaticMethod();
    }//function main()

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/



/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Main