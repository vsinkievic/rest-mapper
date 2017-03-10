 
 /*------------------------------------------------------------------------
    File        : WebRequestMockTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Sat Jun 25 09:44:14 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Net.*.
using OpenEdge.Web.*.
using OpenEdge.Core.Assert.
using bpmid.rest-mapper.*.

block-level on error undo, throw.

class bpmid.rest-mapper.WebRequestMockTest:
	
	def var moRequest as IWebRequest no-undo.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void extractPathInfoFromUri(  ):  
        message subst("Test: &1", program-name(1)).
        moRequest:URI = new URI("line.lateko.lt/cgi-bin/cgiip.exe/WService=line/test").
        Assert:Equals("/test", moRequest:PathInfo).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
   
    @Setup.
    method public void setUp(  ):
        
        moRequest = new WebRequestMock().
        return.

    end method.
    
    /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/

    @TearDown.
    method public void tearDown(  ):
        
        if valid-object(moRequest)
        then delete object moRequest.
        
        return.

    end method.
      
end class.