package traits;

#if macro

import haxe.macro.ComplexTypeTools;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;


/**
* Various helpers for traits processing
*
*/
class FixTools {


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Replace short types with full types
    *
    */
    static public function fixExpr (expr:Expr) : Expr {
        if( expr == null ) return null;

        switch(expr.expr){
            //found identifier
            case EConst(CIdent(ident)):
                var type : Ref<BaseType> = FixTools.resolveType(ident);
                if( type != null ){
                    return Context.parse(type.toString(), expr.pos);
                }

            //new object creation
            case ENew(t,params):
                var type : TypePath = FixTools.fixTypePath(t);
                for(i in 0...params.length){
                    params[i] = FixTools.fixExpr(params[i]);
                }
                return {expr:ENew((type == null ? t : type),params), pos:expr.pos};

            //typed cast
            case ECast(e,t):
                e = FixTools.fixExpr(e);
                t = FixTools.fixComplexType(t);
                return {expr:ECast(e,t),pos:expr.pos};

            //try...catch
            case ETry(e,catches):
                e = FixTools.fixExpr(e);
                for(c in catches){
                    c.type = FixTools.fixComplexType(c.type);
                    c.expr = FixTools.fixExpr(c.expr);
                }
                return {expr:ETry(e,catches), pos:expr.pos};

            //Macro thing: http://haxe.1354130.n2.nabble.com/Type-parameter-substitution-tp6966489p6967899.html
            case ECheckType(e,t):
                e = FixTools.fixExpr(e);
                t = FixTools.fixComplexType(t);
                return {expr:ECheckType(e,t),pos:expr.pos};

            //var declaration
            case EVars(vars):
                var fixed : Array<Var> = [];
                for(v in vars){
                    fixed.push({
                        name : v.name,
                        expr : FixTools.fixExpr(v.expr),
                        type : FixTools.fixComplexType(v.type)
                    });
                }
                return {expr:EVars(fixed),pos:expr.pos};
            //other expressions
            case _:
                return ExprTools.map(expr, FixTools.fixExpr);
        }

        return expr;
    }//function fixExpr()


    /**
    * Get type with full package
    *
    */
    static public inline function fixTypePath (type:TypePath) : TypePath {
        return {
            sub    : type.sub,
            params : type.params,
            pack   : FixTools.resolveType(type.name).get().pack,
            name   : type.name
        }
    }//function fixTypePath()


    /**
    * Get full type for specified imported type name
    *
    */
    static public function resolveType (name:String) : Ref<BaseType> {
        var type : Type = null;
        try{
            type = Context.getType(name);
        }catch(e:Dynamic){
            return null;
        }

        return FixTools.getTypeRef(type);
    }//function resolveType()


    /**
    * Get Ref instance for specified type
    *
    */
    static public function getTypeRef (type:Type) : Ref<BaseType> {
        return switch(type){
            case TMono(t)       : if( t == null ) null else getTypeRef(t.get());
            case TEnum(t,_)     : t;
            case TInst(t,_)     : t;
            case TType(t,_)     : t;
            case TAbstract(t,_) : t;
            case _              : null;
        }
    }//function getTypeRef()


    /**
    * Fix types in type parameters (Array<SomeClass<OtherClass>>)
    *
    */
    static public function fixTypeParam (param:TypeParamDecl) : Void {
        for(i in 0...param.params.length){
            FixTools.fixTypeParam(param.params[i]);
        }
        for(i in 0...param.constraints.length){
            param.constraints[i] = FixTools.fixComplexType(param.constraints[i]);
        }
    }//function fixTypeParam()


    /**
    * Get complex type with full package
    *
    */
    static public inline function fixComplexType (ct:ComplexType) : ComplexType {
        if (ct == null){
            return null;
        }else{
            try {
                return TypeTools.toComplexType( ComplexTypeTools.toType(ct) );
            } catch (e:Dynamic) {
                return ct;
            }
        }
    }//function fixComplexType()


/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    //code...

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class FixTools

#end