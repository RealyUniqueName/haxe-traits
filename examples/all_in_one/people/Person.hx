package people;


enum EGender{
    GMale;
    GFemale;
}


/**
* Base person class
*
*/
class Person {

    //person's name
    public var name : String;
    //male/female
    public var gender : EGender;

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
    public function new (name:String, gender:EGender) : Void {
        this.name   = name;
        this.gender = gender;
    }//function new()


    /**
    * Greet another person
    *
    */
    public function greet (p:Person) : Void {
        trace(this.name + ":\n\t" + "Hello, " + p.name);
    }//function greet()


/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Person