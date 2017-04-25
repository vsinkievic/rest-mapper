/*------------------------------------------------------------------------
    File        : RestError
    Purpose     : Error which is shown in response as JSON with proper status and common structure.
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Tue Jun 21 17:27:56 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Lang.AppError.

block-level on error undo, throw.

class bpmid.rest-mapper.RestError inherits AppError: 

	define public property err as character no-undo 
	get.
	private set. 

	define public property msg as character no-undo 
	get.
	private set. 

	define public property responseStatus as integer no-undo 
	get.
	private set. 
	
	define public property errorStack as char no-undo
	get:
	    if errorStack > ""
	    then return errorStack.
	    else return callStack.
	end.
	private set.
	
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	constructor public RestError ( iResponseStatus as int, oError as Error ):
		super ().
		def var oAppError as Progress.Lang.AppError no-undo.
		 
		responseStatus = iResponseStatus.
		msg = oError:GetMessage(1).
		err = oError:GetClass():TypeName.
		
		if err ="Progress.Lang.AppError"
		then do:
		    oAppError = cast(oError, Progress.Lang.AppError).
		    if oAppError:ReturnValue > ""
		    then msg = msg + oAppError:ReturnValue.
		end.
		
		if oError:CallStack > ""
		then this-object:errorStack = oError:CallStack.
		
	end constructor.

    constructor public RestError ( iResponseStatus as int, cMessage as char ):
        super ().
        
        responseStatus = iResponseStatus.
        msg = cMessage.
        err = "Error".
        
        AddMessage(cMessage, 200).
        
    end constructor.

    constructor public RestError ( iResponseStatus as int, cMessage as char, cErrorType as char ):
        super ().
        
        responseStatus = iResponseStatus.
        msg = cMessage.
        err = cErrorType.
        
    end constructor.
    
    method public override void AddMessage(MessageString as character, MessageNum as integer):
        super:AddMessage(MessageString, MessageNum).
    end method. /* AddMessage */
end class.