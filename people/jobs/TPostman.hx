package people.jobs;

import traits.ITrait;



/**
* Postman job
*
*/
interface TPostman extends ITrait{
    //check static vars inheritence
    static public inline var INHERITED_STATIC_FIELD = "This is inlined static var of people.jobs.TPostman";

    //town, where postman works
    public var town : String = "Simpleburg";


    /**
    * Send message
    *
    */
    public function send (message:String) : Void {
        //since this code will be compiled in context of another class, you can use
        //fields of that class here
        trace(this.name + " sent your message: '" + message + "' from "+ this.town);
    }//function send()

}//interface TPostman