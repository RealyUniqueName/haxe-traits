package traits;

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
    macro static public function cls () : Expr/* Of<Class<Dynamic>> */ {
        var cls = Context.getLocalClass().toString();
        return Context.parse(cls, Context.currentPos());
    }//function cls()

#if macro
    //traits fields
    static private var _fields : TraitsMap;


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
        //save trait's fields map
        __fields().set(cls.module + "." + cls.name, _fieldsMap(fields));
    }//function _save()


    /**
    * Get trait fields map
    *
    */
    static private inline function _get (cls:ClassType) : FieldsMap {
        return __fields().get(cls.module + "." + cls.name);
    }//function _get()


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
                // switch(field.kind){
                //     case FFun(f): _fixExpr(f.expr);
                //     case _:
                // }
                continue;
            }

            //remove bodies from methods
            switch(field.kind){
                //method
                case FFun(f): f.expr = null;
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

        for(i in cls.interfaces){
            tfm = _get(i.t.get());

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
                    //descendant hase such field. Check compatibility
                    }else{
                        if( !_fieldsMatch(dfield, tfield) ){
                            Context.error(cls.name + "." + dfield.name + " type does not match " + i.t.toString() + "." + tfield.name, Context.currentPos());
                        }
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
            access : field.access,
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


    // /**
    // * Replace short types with full types
    // *
    // */
    // static private function _fixExpr (expr:Expr) : Void {
    //     if( expr == null ) return;
    //     _fixExprDef(expr.expr);
    // }//function _fixExpr()


    // /**
    // * Replace short types with full types
    // *
    // */
    // static private function _fixExprDef (exprDef:ExprDef) : Void {
    //     switch(exprDef){
    //         case EWhile(econd,e,normalWhile):
    //             _fixExpr(econd);
    //             _fixExpr(e);
    //         case EVars(vars):
    //             for(v in vars){
    //                 _fixExpr(v.expr);
    //             }
    //         case EUntyped(e):
    //             _fixExpr(e);
    //         case EUnop(op,postFix,e):
    //             _fixExpr(e);
    //         case ETry(e,catches):
    //             _fixExpr(e);
    //             for(c in catches){
    //                 _fixExpr(c.expr);
    //             }
    //         case EThrow(e):
    //             _fixExpr(e);
    //         case ETernary(econd,eif,eelse):
    //             _fixExpr(econd);
    //             _fixExpr(eif);
    //             _fixExpr(eelse);
    //         case ESwitch(e,cases,edef):
    //             _fixExpr(e);
    //             for(c in cases){
    //                 for(v in c.values){
    //                     _fixExprDef(v.expr);
    //                 }
    //                 _fixExpr(c.guard);
    //                 _fixExpr(c.expr);
    //             }
    //             _fixExpr(edef);
    //         case EReturn(e):
    //             _fixExpr(e);
    //         case EParenthesis(e):
    //             _fixExpr(e);
    //         case EObjectDecl(fields):
    //             for(f in fields){
    //                 _fixExpr(f.expr);
    //             }
    //         case ENew(t,params):
    //             for(e in params){
    //                 _fixExpr(e);
    //             }
    //         case EMeta(s,e):
    //             _fixExpr(e);
    //         case EIn(e1,e2):
    //             _fixExpr(e1);
    //             _fixExpr(e2);
    //         case EIf(econd,eif,eelse):
    //             _fixExpr(econd);
    //             _fixExpr(eif);
    //             _fixExpr(eelse);
    //         case EFunction(name,f):
    //             _fixExpr(f.expr);
    //         case EFor(it,expr):
    //             _fixExpr(it);
    //             _fixExpr(expr);
    //         case EField(e,field):
    //             _fixExpr(e);
    //         case EDisplayNew(t):
    //         case EDisplay(e,isCall):
    //             _fixExpr(e);
    //         case EContinue:
    //         //replace short type with full type
    //         case EConst(c):
    //             switch(c){
    //                 case CIdent(t):
    //                     switch(Context.getType(t)){
    //                         case TInst(t,p):
    //                             trace(Context.parse(t.toString(), Context.currentPos()));
    //                         case _:
    //                     }
    //                 case _:
    //             }
    //         case ECheckType(e,t):
    //             _fixExpr(e);
    //         case ECast(e,t):
    //             _fixExpr(e);
    //         case ECall(e,params):
    //             _fixExpr(e);
    //             for(p in params){
    //                 _fixExpr(p);
    //             }
    //         case EBreak:
    //         case EBlock(exprs):
    //             for(e in exprs){
    //                 _fixExpr(e);
    //             }
    //         case EBinop(op,e1,e2):
    //             _fixExpr(e1);
    //             _fixExpr(e2);
    //         case EArrayDecl(values):
    //             for(e in values){
    //                 _fixExpr(e);
    //             }
    //         case EArray(e1,e2):
    //             _fixExpr(e1);
    //             _fixExpr(e2);
    //     }
    // }//function _fixExprDef()

#end
}//class Trait
