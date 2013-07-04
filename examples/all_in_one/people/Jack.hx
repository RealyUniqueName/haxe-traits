package people;

import people.jobs.TChef;
import people.jobs.TPostman;
import people.Person.EGender;
import traits.Trait;


/**
* Just a man with two jobs
*
*/
class Jack extends Person implements TChef implements TPostman {


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


    /**
    * Override TPostman.send method.
    * Send packed message
    *
    */
    public function send (message:String) : Void {
        message = this.pack(message);

        //this is like `super.parentMethod()` call but for traits
        Trait.parent(TPostman).send(message);
    }//function send()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Jack