 
 /*------------------------------------------------------------------------
    File        : RestServiceTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Fri Apr 07 10:10:42 EEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.*.
using bpmid.rest-mapper.*.

block-level on error undo, throw.

class bpmid.rest-mapper.RestServiceTest inherits RestService:
	def temp-table ttObject serialize-name "objects"
	   field my_key as char serialize-name "myKey"
	   field my_val as char serialize-name "myVal"
	   .
    def temp-table ttSub serialize-name "subs"
       field my_key  as char serialize-name "myKey"
       field sub_key as char serialize-name "subKey"
       field sub_val as char serialize-name "subVal".
       
    def temp-table ttHub serialize-name "hubs"
       field my_key  as char serialize-name "myKey"
       field hub_key as char serialize-name "hubKey"
       field hub_val as char serialize-name "hubVal".
       
    def dataset dsObject serialize-hidden for ttObject, ttSub, ttHub
        data-relation dr1 for ttObject, ttSub relation-fields(my_key, my_key) nested foreign-key-hidden
        data-relation dr2 for ttObject, ttHub relation-fields(my_key, my_key) nested foreign-key-hidden
	.  
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void saveDatasetAsObject(  ):  
        def var cJson as longchar no-undo.        
        // given
        create ttObject.
        ttObject.my_key = "raktas".
        ttObject.my_val = "reiksme".
        create ttSub. ttSub.my_key = "raktas". ttSub.sub_key = "subRaktas". ttSub.sub_val = "1".
        create ttSub. ttSub.my_key = "raktas". ttSub.sub_key = "kitasRakt". ttSub.sub_val = "2".

        create ttHub. ttHub.my_key = "raktas". ttHub.hub_key = "subRaktas". ttHub.Hub_val = "1".
        create ttHub. ttHub.my_key = "raktas". ttHub.hub_key = "kitasRakt". ttHub.Hub_val = "2".
        
                
        // when
        cJson = buf2jsonObject(dataset dsObject:handle).
/*        def var cOrigJson as longchar no-undo.                    */
/*        dataset dsObject:write-json ("longchar", cOrigJson, true).*/
/*        copy-lob from cOrigJson to file "c:/temp/json.json".      */
        
        // then
        copy-lob from cJson to file "target/saveDatasetAsObject.json".
        
      //  Assert:equals('~{"myKey":"raktas","myVal":"reiksme"}', cJson).
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void saveTempTableAsArray(  ):  
        def var cJson as longchar no-undo.        
        // given
        create ttObject. ttObject.my_key = "raktas 1". ttObject.my_val = "reiksme 1".
        create ttObject. ttObject.my_key = "raktas 2". ttObject.my_val = "reiksme 2".
                
        // when
        cJson = buf2jsonArray(buffer ttObject:handle).
        
        // then
        copy-lob from cJson to file "target/saveTempTableAsArray.json".
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void saveTempTableAsFormattedArray(  ):  
        def var cJson as longchar no-undo.        
        // given
        create ttObject. ttObject.my_key = "raktas 1". ttObject.my_val = "reiksme 1".
        create ttObject. ttObject.my_key = "raktas 2". ttObject.my_val = "reiksme 2".
        this-object:formatJson = true.
                
        // when
        cJson = buf2jsonArray(buffer ttObject:handle).
        
        // then
        copy-lob from cJson to file "target/saveTempTableAsFormattedArray.json".
    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void saveTempTableAsObject(  ):  
        def var cJson as longchar no-undo.        
        // given
        create ttObject.
        ttObject.my_key = "raktas".
        ttObject.my_val = "reiksme".
                
        // when
        cJson = buf2jsonObject(buffer ttObject:handle).
        
        // then
        copy-lob from cJson to file "target/saveTempTableAsObject.json".
     //   Assert:equals('~{"myKey":"raktas","myVal":"reiksme"}', cJson).
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Setup.
	method public void setup(  ):  
        empty temp-table ttObject.
        empty temp-table ttSub.
        dataset dsObject:empty-dataset ().
        this-object:formatJson = false.
	end method.

end class.