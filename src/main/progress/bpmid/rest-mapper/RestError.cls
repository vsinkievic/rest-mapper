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

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	constructor public RestError ( iResponseStatus as int, oAppError as Error ):
		super ().
		
		responseStatus = iResponseStatus.
		msg = oAppError:GetMessage(1).
		err = oAppError:GetClass():TypeName.
		
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