package people;

import people.jobs.TChef;
import people.jobs.TPostman;
import people.Person.EGender;


/**
* Just a man with two jobs
*
*/
class Jack extends Person implements TChef implements TPostman{

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
        super("Jack", EGender.GMale);
    }//function new()


    /**
    * Jack said
    *
    */
    public function say () : Void {
        trace("I have two jobs!");
    }//function say()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Jack