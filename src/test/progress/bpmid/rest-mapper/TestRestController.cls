 
 /*------------------------------------------------------------------------
    File        : TestRestController
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Mon Jun 20 09:04:14 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bpmid.rest-mapper.TestRestController: 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void getIntegerParam( id as int, output responseBody as longchar ):
		
		responseBody = string(id + 1111).
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void getItemPdf( output responseBodyMptr as memptr, output responseContentType as char ):
		
		set-size(responseBodyMptr) = 10.
		responseContentType = "application/pdf".
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void getError( output responseBody as longchar, output responseStatus as int ):
		
		responseBody = "error".
		responseStatus = 401.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void getItem( output responseBody as longchar ):
		
		responseBody = "long item text".
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void getItemUnknownType( input requestContentType as char, output responseContentType as char, output responseBody as longchar, output responseStatus as int):
		responseStatus = 200.
		case requestContentType:
		   when "application/json"
           then do:
    		    responseBody = "json".
    		    responseContentType = "application/json".
    	   end.
    	   
    	   when "application/x-form-urlencoded"
    	   then do:
    	       responseBody = "html".
    	       responseContentType = "text/html".
    	   end.
    	   
    	   otherwise do:
    	       responseStatus = 500.
    	       responseBody = "unsupported".
    	       /* when responseContentType is set - it must set default */
    	   end.
    	end.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void throwProgressError( output responseBody as longchar ):
		
		def var cArray as char extent 2.
		def var i as int no-undo.
		do i = 1 to 3:
		  cArray[i] = "not existing extent!".
		end.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void throwAppError( output responseBody as longchar ):
		
		undo, throw new Progress.Lang.AppError("My app error", 201).

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void throwSimpleRestError( output responseBody as longchar  ):
		
		undo, throw new bpmid.rest-mapper.RestError(401, "Does not work").

	end method.    

end class.