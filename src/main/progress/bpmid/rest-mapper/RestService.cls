 
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
     
    method protected longchar buf2jsonArray(h as handle):
        def var s as longchar no-undo.
        
        h:write-json("longchar", s, true).
        if s = ? or length(s) <=4
        then return "[]".
        
        s = substr(s, index(s, ":") + 1).
        s = substr(s, 1, length(s) - 2).
        return s.
    end.
    
    method protected longchar buf2jsonObject(h as handle):
        def var s as longchar no-undo.
        
        h:write-json("longchar", s, true).
        s = substr(s, index(s, "[") + 1).
        s = substr(s, 1, length(s) - 4).
        return s.
    end.
    

end class.