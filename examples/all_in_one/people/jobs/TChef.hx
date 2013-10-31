package people.jobs;

import traits.ITrait;
import traits.Trait;



/**
* Chef job
*
*/
interface TChef extends ITrait{
    /** pretty obvious */
    static public inline var SOME_VAR : Int = 10;

    /**
    * Check static methods
    *
    */
    static public function inheritedStaticMethod () : Void {
        //here is how to know current context class
        var cls : Class<TChef> = Trait.self();

        //also this is allowed
        var inc : Int = Trait.self().SOME_VAR + 1;

        trace("I am declared in people.jobs.TChef and called from " + Type.getClassName(cls));
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