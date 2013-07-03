package people.jobs;

import haxe.xml.Fast;
import traits.ITrait;
import traits.Trait;



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
        //here is how to know current context class
        var cls : Class<TChef> = Trait.self();

        trace("I am called from " + Type.getClassName(cls));
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