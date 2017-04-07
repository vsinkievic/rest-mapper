 
 /*------------------------------------------------------------------------
    File        : RestService
    Purpose     : Parent class for REST services with common JSON mapping infrastructure (methods)
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Sat Jul 16 12:55:34 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bpmid.rest-mapper.RestService abstract: 
     
	define public property formatJson as logical initial false no-undo 
	get.
	set. 

    method protected longchar buf2jsonArray(h as handle):
        def var s as longchar no-undo.
        def var i as int no-undo.
        
        h:write-json("longchar", s, formatJson).
        if s = ? or length(s) <=4
        then return "[]".
        
        i = index(s, ":").
        return substr(s, i + 1, r-index(s, "}") - i - 1).
    end.
    
    method protected longchar buf2jsonObject(h as handle):
        def var s as longchar no-undo.
        def var i as int no-undo.
        
        h:write-json("longchar", s, formatJson).
        i = index(s, "[").
        return substr(s, i + 1, r-index(s, "]") - i - 1).
    end.
    

end class.