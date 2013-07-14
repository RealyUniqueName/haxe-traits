package traits;

import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

private typedef FieldsMap = Map<String,Field>;
private typedef TraitsMap = Map<String,FieldsMap>;


/**
* Всякие разные утилиты для кодогенерации
*
*/
class Trait {

    /**
    * Returns current class (for using in traits code)
    *
    */
    macro static public function self () : Expr/* Of<Class<Dynamic>> */ {
        var cls = Context.getLocalClass().toString();
        return Context.parse(cls, Context.currentPos());
    }//function self()


    /**
    * For `super.parentMethod()` calls emulation
    *
    * @param cls - one of traits classes
    */
    macro static public function parent (traitCls:Expr) : Expr {
        var trait : String = switch(traitCls.expr){
            case EConst(CIdent(t)): t;
            case EField(_,t): t;
            case _: null;
        }
        if( trait == null ){
            throw "Trait.parent() accepts only names of classes";
        }

        var currentClass = Context.getLocalClass();

        //ensure current class implements that trait {
            var hasThisTrait : Bool = false;

            for(int in currentClass.get().interfaces){
                if( int.t.get().name == trait ){
                    if( Trait._get(int.t.get()) == null ){
                        throw int.t.toString() + " is not a trait";
                    }
                    hasThisTrait = true;
                    break;
                }
            }

            if( !hasThisTrait ){
                throw currentClass.toString() + " does not implement " + trait;
            }
        //}

        return Context.parse('cast(this, $trait)', Context.currentPos());
    }//function parent()


#if macro
    //traits fields
    static private var _fields : TraitsMap;
    /** if class implements several traits, compiler will call `build` for such class several times. */
    static private var _processed : Map<String,Bool> = new Map();


    /**
    * Clear cache of processed traits
    *
    */
    static public function clearCache () : Void {
        _fields    = new Map();
        _processed = new Map();
    }//function clearCache()


    /**
    * Get `_fields` object
    *
    */
    static private function __fields () : TraitsMap {
        if( _fields == null ){
            _fields = new Map();
        }
        return _fields;
    }//function __fields()


    /**
    * Create fields map
    *
    */
    static private function _fieldsMap (fields:Array<Field>) : FieldsMap {
        var fieldsMap : FieldsMap = new Map();
        for(f in fields){
            fieldsMap.set(f.name, f);
        }
        return fieldsMap;
    }//function _fieldsMap()


    /**
    * Save trait fields
    *
    */
    static private inline function _save (cls:ClassType, fields:Array<Field>) : Void {
        fields = Trait._fixTypes(fields);
        //save trait's fields map
        Trait.__fields().set(cls.module + "." + cls.name, _fieldsMap(fields));
    }//function _save()


    /**
    * Get trait fields map
    *
    */
    static private inline function _get (cls:ClassType) : FieldsMap {
        return __fields().get(cls.module + "." + cls.name);
    }//function _get()


    /**
    * Insert full classnames instead of imported shortened (by imports) names
    *
    */
    static private function _fixTypes (fields:Array<Field>) : Array<Field> {
        var fixed : Array<Field> = [];

        for(f in fields){
            f = Trait._copyField(f);
            //in bodies of functions replace shortened types
            switch(f.kind){
                //method
                case FFun(f): f.expr = ExprTools.map(f.expr, Trait._fixExpr);
                //other
                case _:
            }//switch(kind)
            fixed.push(f);
        }

        return fixed;
    }//function _fixTypes()


    /**
    * Build traits / add trait fields to classes
    *
    */
    macro static public function build() : Array<Field> {
        var pos    = Context.currentPos();
        var cls    = Context.getLocalClass().get();
        var fields = Context.getBuildFields();

        //trait
        if( cls.isInterface ){
            fields = _processTrait(cls, fields);

        //trait descendant
        }else{

            //to prevent processing one class several times
            if( _processed.exists(cls.module + "." + cls.name) ){
                return fields;
            }
            _processed.set(cls.module + "." + cls.name, true);

            fields = _processDescendant(cls, fields);
        }

        return fields;
    }//function build()


    /**
    * Process trait
    *
    */
    static private function _processTrait (cls:ClassType, fields:Array<Field>) : Array<Field> {
        _save(cls, fields);
        var _fields : Array<Field> = [];

        for(f in fields){
            var field : Field = _copyField(f);

            //interface is not allowed to have static fields
            if( field.access.has(AStatic) ) {
                continue;
            }

            //remove bodies from methods
            switch(field.kind){
                //method
                case FFun(fn):
                    fn.expr = null;
                    field.access.remove(AOverride);

                    #if !display
                        //create field for ".parent" calls
                        var pField : Field = _copyField(f);
                        pField.name = "_" + StringTools.replace(Context.getLocalClass().toString(), ".", "_") + "_" + pField.name;
                        pField.access.remove(AOverride);
                        _get(cls).set(pField.name, pField);
                    #end
                //var
                case FVar(t,e):
                    field.kind = FVar(t,null);

                //other
                case _:
            }//switch(kind)

            _fields.push(field);
        }//for(fields)

        return _fields;
    }//function _processTrait()


    /**
    * Process trait descendant
    *
    */
    static private function _processDescendant (cls:ClassType, fields:Array<Field>) : Array<Field> {
        //descendant fields map
        var dfm : FieldsMap = _fieldsMap(fields);
        //trait fields map
        var tfm : FieldsMap;
        //source field structure
        var dfield : Field;
        //trait field structure
        var tfield : Field;

        for(trait in cls.interfaces){
            tfm = _get(trait.t.get());

            //need to add trait fields
            if( tfm != null ){

                for(fname in tfm.keys()){
                    dfield = dfm.get(fname);
                    tfield = tfm.get(fname);
                    //if descendant does not have such field, copy trait field
                    if( dfield == null ){
                        switch(tfield.kind){
                            //methods
                            case FFun(f):
                                if( f.expr != null ) fields.push(_copyField(tfield));
                            //other
                            case _:
                                fields.push(_copyField(tfield));
                        }//switch(tfield.kind)
                    //descendant has such field.
                    }else{
                        //Check compatibility
                        if( !_fieldsMatch(dfield, tfield) ){
                            Context.error(cls.name + "." + dfield.name + " type does not match " + trait.t.toString() + "." + tfield.name, Context.currentPos());
                        }
                        _handleParentCalls(cls, trait.t, dfield);
                    }
                }//for()

            }//if( tfm != null )
        }//for(interfaces)

        return fields;
    }//function _processDescendant()


    /**
    * Check fields are compatible
    *
    */
    static private function _fieldsMatch (f1:Field, f2:Field) : Bool {
        // trace(f1);
        // trace(f2);
        return true;
    }//function _fieldsMatch()


    /**
    * Copy field structure
    *
    */
    static private inline function _copyField (field:Field) : Field {
        return {
            name   : field.name,
            doc    : field.doc,
            access : field.access.copy(),
            kind   : switch(field.kind){
                //method
                case FFun(f): FFun(_copyFunction(f));
                case _: field.kind;
            },
            pos    : field.pos,
            meta   : field.meta
        };
    }//function _copyField()


    /**
    * Copy function definition
    *
    */
    static private inline function _copyFunction (fn:Function) : Function {
        return {
            args   : fn.args,
            ret    : fn.ret,
            expr   : fn.expr,
            params : fn.params
        };
    }//function _copyFunction()


    /**
    * Replace short types with full types
    *
    */
    static private function _fixExpr (expr:Expr) : Expr {
        switch(expr.expr){
            //found identifier
            case EConst(CIdent(ident)):
                var typeExpr : Expr = Trait._resolveType(ident, expr.pos);
                if( typeExpr != null ){
                    return typeExpr;
                }

            //new object creation
            case ENew(t,_):
                var typeExpr : Expr = Trait._resolveType(t.name, expr.pos);
                if( typeExpr != null ){
                    return typeExpr;
                }

            //other expressions
            case _:
                return ExprTools.map(expr, Trait._fixExpr);
        }

        return expr;
    }//function _fixExpr()


    /**
    * Get expression with full class path for specified identifier
    *
    */
    static private function _resolveType (type:String, pos:Position) : Expr {
        var t : Type = null;
        try{
            t = Context.getType(type);
        }catch(e:Dynamic){
            return null;
        }

        return  switch(t){
            case TMono(t)       : Context.parse(t.toString(), pos);
            case TEnum(t,_)     : Context.parse(t.toString(), pos);
            case TInst(t,_)     : Context.parse(t.toString(), pos);
            case TType(t,_)     : Context.parse(t.toString(), pos);
            case TAnonymous(t)  : Context.parse(t.toString(), pos);
            case TAbstract(t,_) : Context.parse(t.toString(), pos);
            case _              : null;
        }
    }//function _resolveType()


    /** the trait, whis is being processed right now */
    static private var _trait : Ref<ClassType>;

    /**
    * Replace all `Trait.parent(TSomeTrait).someMethod` with corresponding function
    * calls to emulate `super.someMethod` behavior
    *
    */
    static private function _handleParentCalls (cls:ClassType, trait:Ref<ClassType>, field:Field) : Void {
        #if display
            return;
        #end

        _trait = trait;

        switch(field.kind){
            case FFun(f):
                f.expr = ExprTools.map(f.expr, _replaceParentCalls);
            case _:
        }
    }//function _handleParentCalls()


    /**
    * Function for ExprTools.map() to replace `Trait.parent(TSomeTrait).someMethod`
    *
    */
    static private function _replaceParentCalls (expr:Expr) : Expr {
        switch(expr.expr){
            case ECall({expr:EField(e,f),pos:pos},p):
                if( _isParentCall(e) ){
                    var superField : String = "_" + StringTools.replace(_trait.toString(), ".", "_") + "_";
                    return {
                        expr:ECall({
                            expr:EField({expr:EConst(CIdent("this")), pos:pos}, superField + f),
                            pos : pos
                        },
                        p),
                        pos:pos
                    };
                }
                return {expr:expr.expr, pos:expr.pos};
            case _:
                return expr;//ExprTools.map(expr, _replaceParentCalls);
        }
    }//function _replaceParentCalls()


    /**
    * Check if this ExprDef is `Trait.parent()` call
    *
    */
    static private function _isParentCall (e:Expr) : Bool {
        return switch(e.expr){
            case EField({expr:EConst(CIdent("traits")),pos:pos},"Trait") : true;
            case EField(e,field)         : (_isParentCall(e) && field == "parent" );
            case ECall(e,_)              : _isParentCall(e);
            case EConst(CIdent("Trait")) : true;
            case _                       : false;
        }
    }//function _isParentCall()

#end
}//class Trait
