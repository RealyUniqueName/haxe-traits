package people;


/**
* Jack's son
*
*/
class Timmy extends Jack{


    /**
    * Override inherited static methods
    *
    */
    static public function inheritedStaticMethod () : Void {
        var cls : Class<people.jobs.TChef> = traits.Trait.self();
        trace('I am declared in people.jobs.TChef, overriden in people.Timmy and called from ' + Type.getClassName(cls));
    }


    /**
    * Timmy said
    *
    */
    override public function say () : Void {
        trace('I have a father');
    }//function say()


}//class Timmy