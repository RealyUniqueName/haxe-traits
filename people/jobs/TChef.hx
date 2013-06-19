package people.jobs;

import traits.ITrait;



/**
* Postman job
*
*/
interface TChef extends ITrait{


    /**
    * Check static methods
    *
    */
    static public function inheritedStaticMethod () : Void {
        trace("This is static method of TChef called as static method of " + Type.getClassName(traits.Trait.cls()));
    }//function inheritedStaticMethod()


    /**
    * Cook a meal
    *
    */
    public function cook (dish:String) : Void {
        //since this code will be compiled in context of another class, you can use
        //fields of that class here
        trace(this.name + " cooked a delicious " + dish);
    }//function cook()

}//interface TChef