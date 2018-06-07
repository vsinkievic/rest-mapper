 
 /*------------------------------------------------------------------------
    File        : TestWebRequestExecutor
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Mon Jun 20 09:21:55 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using bpmid.rest-mapper.*.
using OpenEdge.Core.Assertion.*.
using OpenEdge.Core.Assert from propath.
using OpenEdge.Web.IWebRequest.

block-level on error undo, throw.

class bpmid.rest-mapper.TestWebRequestExecutor:
	 
	 def var moRequest as IWebRequest.
	 def var moExec as WebRequestExecutor.
	 
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void catchAppError( ):  
        message subst("Test: &1", program-name(1)).
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "throwAppError", "").
        
        Assert:IsTrue(index(moExec:responseBody, "My app error") > 0). 
        Assert:Equals(500, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void catchProgressError( ):  
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "".
        moExec:defaultResponseContentType = "text/plain".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "throwProgressError", "").
        
        Assert:Equals("** Array subscript 3 is out of range. (26)", moExec:responseBody).  /* patikslinti, turi b�ti progress klaidos tekstas */
        Assert:Equals(500, moExec:responseStatus).
        Assert:Equals("text/plain", moExec:responseContentType).
        
        return.
 
	end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void catchSimpleRestError(  ):  
        message subst("Test: &1", program-name(1)).
        
        moExec:defaultResponseContentType = "application/json".
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "throwSimpleRestError", "").
        
        Assert:Equals('~{"err":"Error","msg":"Does not work","message":"Does not work","path":null}', moExec:responseBody).  /* patikslinti, turi b�ti progress klaidos tekstas */
        Assert:Equals(401, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
		return.
 
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void errorInReponse(  ):  
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getError", "").
        
        Assert:Equals("error", moExec:responseBody).
        Assert:Equals(401, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
        return.
 
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void provideIntegerPathParam(  ):  
        message subst("Test: &1", program-name(1)).

        moExec:defaultResponseContentType = "application/json".
        
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getIntegerParam", "id=1234").
        
        Assert:Equals("2345", moExec:responseBody).
        Assert:Equals(200, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).

		return.
 
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @Test.
	method public void requestItem(  ):
        message subst("Test: &1", program-name(1)).
	    
        moExec:defaultResponseContentType = "application/json".
        
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getItem", "").
        
        Assert:Equals("long item text", moExec:responseBody).
        Assert:Equals(200, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
        return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void requestItemPdf(  ):  
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getItemPdf", "").
        
        Assert:Equals(10, get-size(moExec:responseBodyMptr)).
        Assert:Equals("application/pdf", moExec:responseContentType).
        Assert:Equals(200, moExec:responseStatus).
        
		return.
 
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @Test.
	method public void requestItemUnknownTypeAsJson(  ):
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "application/json".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getItemUnknownType", "").
        
        Assert:Equals("json", moExec:responseBody).
        Assert:Equals(200, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
		return.

	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @Test.
    method public void requestItemUnknownTypeAsHtml(  ):
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "application/x-form-urlencoded".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getItemUnknownType", "").
        
        Assert:Equals("html", moExec:responseBody).
        Assert:Equals(200, moExec:responseStatus).
        Assert:Equals("text/html", moExec:responseContentType).
        
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @Test.
    method public void requestItemUnknownTypeAsUnsupported(  ):
        message subst("Test: &1", program-name(1)).
        
        moExec:requestContentType = "".
        moExec:ExecuteRequest(?, "bpmid.rest-mapper.TestRestController", "getItemUnknownType", "").
        
        Assert:Equals("unsupported", moExec:responseBody).
        Assert:Equals(500, moExec:responseStatus).
        Assert:Equals("application/json", moExec:responseContentType).
        
        return.

    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Setup.
	method public void SetupTest(  ):  

        moRequest = dynamic-new "bpmid.rest-mapper.WebRequestMock" ().
        moExec = new WebRequestExecutor().
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void TearDownTest(  ):  
        message subst("Test: &1", program-name(1)).

        set-size(moExec:responseBodyMptr) = 0.
        
        if valid-object(moExec)
        then delete object moExec.
        
        if valid-object(moRequest)
        then delete object(moRequest).
        
		return.
 
	end method.

end class.