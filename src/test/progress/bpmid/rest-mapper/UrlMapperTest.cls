 
 /*------------------------------------------------------------------------
    File        : RequestMapperTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Wed Jun 22 09:39:44 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/
/* 
parameters:
    url
    method
    consumes 
    accept
    
    accept is converted to produces. if accept was not set - any produces is accepted.  

   1. if url only is set - any methods, any consumes, accept, produces
   2. if url and produces are set - any methods, any consumes consumes, visi accept
   3. if url and methods are set - any consumes, accept, produces
   4. if url, method, produces, consumes, accept are set
*/
using Progress.Lang.*.
using OpenEdge.Net.URI.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.IWebRequest.
using bpmid.rest-mapper.*.
using OpenEdge.Core.Assertion.*.
using OpenEdge.Core.Assert from propath.

block-level on error undo, throw.

class bpmid.rest-mapper.UrlMapperTest:
	{bpmid/rest-mapper/ttUrlMap.i &name=ttUrlMap &type=temp-table}  
	
	def var moUrlMapper as UrlMapper.
	def var moWebRequest as iWebRequest.
	def var WEB_APP_PATH as char init "/cgi-bin/cgiip.exe/WService=wsbroker1".
	def var mcClass as char no-undo.
	def var mcMethod as char no-undo.
	def var mcPathParams as char no-undo.
	def var mlFound as log no-undo.
	def var mcRoles as char no-undo.

	/*------------------------------------------------------------------------------
	 Purpose:.
	 Notes:
	------------------------------------------------------------------------------*/

	method private void _InitializeUrlMapTable( output table ttUrlMap ):
        empty temp-table ttUrlMap.

        create ttUrlMap.
        ttUrlMap.requestUrl = "/any".
        ttUrlMap.requestMethod = "".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "anyHandler".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/any".
        ttUrlMap.requestMethod = "DELETE".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "anyDeleteHandler".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
		ttUrlMap.controller = "bpmid.rest-mapper.MyController".
		ttUrlMap.ctrlMethod = "getItems".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/~{id}".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "getItemById".


        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/~{id}/subentities".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "getItemSubentitiesByItemId".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/~{id}/rows".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "getItemRowsByItemId".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/~{id}".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "application/pdf".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "getItemByIdReturnPdf".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/byOtherId/~{otherId}".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "application/json".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "getItemByOtherId".
		
        create ttUrlMap.
        ttUrlMap.requestUrl = "/items".
        ttUrlMap.requestMethod = "POST".
        ttUrlMap.consumes = "application/json".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "createItem".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/".
        ttUrlMap.requestMethod = "PUT".
        ttUrlMap.consumes = "application/json".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "updateItem".
        
        create ttUrlMap.
        ttUrlMap.requestUrl = "/items/~{id}".
        ttUrlMap.requestMethod = "DELETE".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "deleteItemById".

        create ttUrlMap.
        ttUrlMap.requestUrl = "/category/~{category}/edit/~{id}/edit".
        ttUrlMap.requestMethod = "GET".
        ttUrlMap.consumes = "".
        ttUrlMap.produces = "".
        ttUrlMap.controller = "bpmid.rest-mapper.MyController".
        ttUrlMap.ctrlMethod = "multiplePathParams".

		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private OpenEdge.Net.URI _Uri( pcPath as char ):
		
        return new URI(subst("http://www.test.lt&1", WEB_APP_PATH) + pcPath).

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void anyDelete(  ):  

        moWebRequest:URI = _Uri("/any").
        moWebRequest:Method = "DELETE".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("anyDeleteHandler", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void anyGet(  ):  

        moWebRequest:URI = _Uri("/any").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("anyHandler", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void anyGetPdf(  ):  

        moWebRequest:URI = _Uri("/any").
        moWebRequest:Method = "GET".
        moWebRequest:SetHeader(new HttpHeader("Accept", "application/pdf")).
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("anyHandler", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void anyPost(  ):  

        moWebRequest:URI = _Uri("/any").
        moWebRequest:Method = "POST".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("anyHandler", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void anyPut(  ):  

        moWebRequest:URI = _Uri("/any").
        moWebRequest:Method = "PUT".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("anyHandler", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void canFindItemByOtherId(  ):  
        moWebRequest:URI = _Uri("/items/byOtherId/555").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemByOtherId", mcMethod).
        Assert:Equals("otherId=555", mcPathParams).
        return.
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void createItem(  ):  
	    
	    moWebRequest:URI = _Uri("/items").
	    moWebRequest:Method = "POST".
	    moWebRequest:ContentType = "application/json".
	    
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
	    
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("createItem", mcMethod).
        Assert:Equals("", mcPathParams).
        
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void deleteItem(  ):  

        moWebRequest:URI = _Uri("/items/1").
        moWebRequest:Method = "DELETE".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("deleteItemById", mcMethod).
        Assert:Equals("id=1", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void getItemAsPdf(  ):  

        moWebRequest:URI = _Uri("/items/1").
        moWebRequest:Method = "GET".
        moWebRequest:SetHeader(new HTTPHeader("Accept", "application/pdf")).
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemByIdReturnPdf", mcMethod).
        Assert:Equals("id=1", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void getItemById(  ):  

        moWebRequest:URI = _Uri("/items/1").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemById", mcMethod).
        Assert:Equals("id=1", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void getItemRowsByItemId(  ):  
        moWebRequest:URI = _Uri("/items/2/rows").
        moWebRequest:Method = "GET".

        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).

        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemRowsByItemId", mcMethod).
        Assert:Equals("id=2", mcPathParams).
        return.
 
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void getItemSubentitiesByItemId(  ):  

        moWebRequest:URI = _Uri("/items/2/subentities").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemSubentitiesByItemId", mcMethod).
        Assert:Equals("id=2", mcPathParams).
        return.
 
    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void getItemNotExistingUrlByItemId(  ):  
        // TODO: atkomentuoti ir sutvarkyti

/*        moWebRequest:URI = _Uri("/items/2/notexist").                                                                                 */
/*        moWebRequest:Method = "GET".                                                                                                  */
/*                                                                                                                                      */
/*        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).*/
/*                                                                                                                                      */
/*        Assert:IsTrue(not mlFound).                                                                                                   */
/*                                                                                                                                      */
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void getItems(  ):  

        moWebRequest:URI = _Uri("/items").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItems", mcMethod).
        Assert:Equals("", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void getItemWithQueryParam(  ):  


        moWebRequest:URI = _Uri("/items/1?filter=hoho").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItemById", mcMethod).
        Assert:Equals("id=1&filter=hoho", mcPathParams).
		return.
 
	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @Test.
    method public void getItemsWithQueryParam(  ):  


        moWebRequest:URI = _Uri("/items?filter=hoho").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("getItems", mcMethod).
        Assert:Equals("filter=hoho", mcPathParams).
        return.
 
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Before.
	method public void InitializeUrlMapper(  ):  
        moUrlMapper = new UrlMapper().
        moUrlMapper:WEB_APP_PATH = WEB_APP_PATH.
        
        _InitializeUrlMapTable(output table ttUrlMap).
        moUrlMapper:LoadUrlMappingsFromTable(table ttUrlMap).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void multiplePathParams(  ):  

        moWebRequest:URI = _Uri("/category/users/edit/222/edit").
        moWebRequest:Method = "GET".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("multiplePathParams", mcMethod).
        Assert:Equals("category=users&id=222", mcPathParams).
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Setup.
	method public void SetupTest(  ):  

        moWebRequest = dynamic-new "bpmid.rest-mapper.WebRequestMock" ().
        mcClass = ?.
        mcMethod = ?.
        mcPathParams = ?.
        mlFound = false.
        mcRoles = ?.
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@TearDown.
	method public void TearDownTest(  ):  
        
        if valid-object(moWebRequest)
        then delete object moWebRequest.
        
		return.
 
	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	@Test.
	method public void updateItem(  ):  
	    
        moWebRequest:URI = _Uri("/items").
        moWebRequest:Method = "PUT".
        moWebRequest:ContentType = "application/json".
        
        mlFound = moUrlMapper:FindRequestExecutor(moWebRequest, output mcClass, output mcMethod, output mcPathParams, output mcRoles).
        
        Assert:IsTrue(mlFound).
        Assert:Equals("bpmid.rest-mapper.MyController", mcClass).
        Assert:Equals("updateItem", mcMethod).
        Assert:Equals("", mcPathParams).
        
		return.
 
	end method.
	
end class.