 
 /*------------------------------------------------------------------------
    File        : WebRequestExecutor
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Mon Jun 20 09:09:20 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Reflect.*.
using bpmid.rest-mapper.*.
using OpenEdge.Web.IWebRequest.

block-level on error undo, throw.

class bpmid.rest-mapper.WebRequestExecutor: 

    def private var mcClassName as char no-undo.
    def private var mcMethodName as char no-undo. 
    
    define static protected property singletonObject as WebRequestExecutor no-undo 
    get.
    set. 

    define public property defaultResponseCharacterEncoding as character no-undo 
    get.
    set (cValue as char): 
        defaultResponseCharacterEncoding = _GetWebEncoding(cValue).
    end. 

	define public property defaultResponseContentType as character initial 'application/json' no-undo 
	get.
	set. 

	define public property responseBody as longchar no-undo 
	get.
	private set. 
    
	define public property responseBodyMptr as memptr no-undo 
	get.
	private set. 
	
    define public property responseCharacterEncoding as character no-undo 
    get.
    private set.

	define public property responseContentType as character no-undo
	get.
	private set.
	 
    define public property requestContentType as character no-undo
    get.
    set.
     
	define public property responseStatus as integer no-undo 
	get.
	private set. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _GetParameter( pcParamList as char, pcName as char ):
		
		def var i as int no-undo.
		def var j as int no-undo.
		def var cKeyValue as char no-undo.
		def var cKey as char no-undo.
		
		do i = 1 to num-entries(pcParamList, "&"):
		    cKeyValue = entry(i, pcParamList, "&").
		    j = index(cKeyValue, "=").
		    if j > 0
		    then do:
		      cKey = substr(cKeyValue, 1, max(1,j - 1)).
		      if cKey = pcName
		      then return substr(cKeyValue, j + 1).
		    end.
		end.
		return "".

	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public static bpmid.rest-mapper.WebRequestExecutor Factory(  ):
        
        if WebRequestExecutor:singletonObject = ?
            then 
        do:
            WebRequestExecutor:singletonObject = new WebRequestExecutor().
        end.
        else return WebRequestExecutor:singletonObject.

    end method.
    
    /*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
		
	constructor public WebRequestExecutor (  ):
		super ().
        defaultResponseCharacterEncoding = _GetWebEncoding(session:cpinternal).
	end constructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _GetWebEncoding( cProgressEncoding as char ):
        
        case cProgressEncoding:
            when "1257" or when "windows-1257" 
            then return "windows-1257".
            
            when "utf-8" then return "utf-8".
            
            otherwise return "".
        end.

	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private character _GetProgressEncoding( cProgressEncoding as char ):
        
        case cProgressEncoding:
            when "1257" or 
            when "windows-1257" 
            then 
                return "1257".
            
            when "utf-8" then 
                return "utf-8".
            
            otherwise 
            return "".
        end.

    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private void _IsParameterValid( oParameter as Parameter, cExpectedDataType as char, cExpectedMode as char):
		
		if cExpectedDataType <> oParameter:DataType:ToString()
		then undo, throw new Progress.Lang.AppError(subst("&1 datatype should be &2 in &3:&4", oParameter:Name, cExpectedDataType, mcClassName, mcMethodName), 299).
 
        if cExpectedMode <> oParameter:Mode:ToString()
        then undo, throw new Progress.Lang.AppError(subst("&1 mode should be &2 in &3:&4", oParameter:Name, cExpectedMode, mcClassName, mcMethodName), 298).

		return.

	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private longchar _OutputRestError( oRestError as RestError ):
        
        if responseContentType = "application/json"
        or ((responseContentType = "" or responseContentType = ?) and defaultResponseContentType = "application/json")
        then return _OutputRestErrorAsJSON( oRestError ).
        else if responseContentType = "text/plain"
                or ((responseContentType = "" or responseContentType = ?) and defaultResponseContentType = "text/plain")
                then return oRestError:msg.
        else return _OutputRestErrorAsHtml( oRestError ). 

    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private longchar _OutputRestErrorAsJSON( oRestError as RestError ):
		
        return subst('~{ "err": "&1", "msg": "&2", "message": "&2" ~}', oRestError:err, oRestError:msg).

	end method.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private longchar _OutputRestErrorAsHtml( oRestError as RestError ):
        
        return subst('<html><body><h1>&1</h1><p>&2</p></body></html>', oRestError:err, oRestError:msg).

    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private void _ResetValues(  ):
		responseBody = "".
		set-size(responseBodyMptr) = 0.
		responseContentType = defaultResponseContentType.
		responseStatus = 200.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private void _FixResponseValues(  ):
		if responseContentType = "" or responseContentType = ?
		then responseContentType = defaultResponseContentType.
		
		if responseCharacterEncoding = "" or responseCharacterEncoding = ?
		then responseCharacterEncoding = defaultResponseCharacterEncoding.
		
		if responseStatus <= 0
		then responseStatus = 500.
		
		if responseBody = ?
		then responseBody = "".

		if get-size(responseBodyMptr) = 0
		then copy-lob from responseBody to responseBodyMptr convert target codepage _getProgressEncoding(responseCharacterEncoding).
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void ExecuteRequest( poRequest as iWebRequest, cClassName as char, cMethodName as char, pcPathParams as char ):
        
        define variable oClass as class Class no-undo.
        define variable oObject as Object no-undo.
        define variable oMethods as class Method extent no-undo.
        define variable oDeclaredParameters as PARAMETER extent no-undo.
        define variable oParameter as Parameter no-undo.
        define variable oInvokeParameters as Progress.Lang.ParameterList no-undo. 
        define variable cRequestBody as longchar no-undo.
        
        define variable methodsCount as integer no-undo.
        define variable parametersCount as integer no-undo.
        
        define variable methodsLoop as integer no-undo.
        define variable parametersLoop as integer no-undo.
        define variable cParamType as char no-undo.
        define variable cParamValue as char no-undo.
        define variable iIntValue as integer no-undo.
        define variable iInt64Value as int64 no-undo.
        
        mcClassName = cClassName.
        mcMethodName = cMethodName.
        
        oClass = Class:GetClass(cClassName).
        
        extent(oMethods) = ?.
        oMethods = oClass:GetMethods().
        
        methodsCount = extent(oMethods).
        do methodsLoop = 1 to methodsCount:
            if (oMethods[methodsLoop]:Name = cMethodName) 
            then do:
                extent(oDeclaredParameters) = ?.    
                oDeclaredParameters = oMethods[methodsLoop]:GetParameters().
                    
                parametersCount = extent(oDeclaredParameters).
                    
                oInvokeParameters = new Progress.Lang.ParameterList(parametersCount).
                    
                do parametersLoop = 1 to parametersCount:
                    oParameter = oDeclaredParameters[parametersLoop].
                    
                    case oParameter:Name:
                        when "requestBody" then do:
                            copy-lob web-context:form-long-input to cRequestBody 
                                convert target codepage session:cpinternal source codepage _getProgressEncoding(defaultResponseCharacterEncoding).
                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                oParameter:DataType:ToString(), 
                                oParameter:Mode:ToString(), 
                                cRequestBody).    
                        end.

                        when "requestContentType" then do:
                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                oParameter:DataType:ToString(), 
                                oParameter:Mode:ToString(), 
                                requestContentType).    
                        end.
                        
                        when "responseBody" then do:
                            _IsParameterValid(oParameter, "LONGCHAR", "OUTPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "LONGCHAR", "OUTPUT", responseBody).    
                        end.
                        
                        when "responseBodyMptr" then do:
                                oInvokeParameters:SETPARAMETER (parametersLoop, 
                                    oParameter:DataType:ToString(), 
                                    oParameter:Mode:ToString(), 
                                    responseBodyMptr).    
                        end.
                            
                        when "responseCharacterEncoding" then do:
                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                oParameter:DataType:ToString(), 
                                oParameter:Mode:ToString(), 
                            responseCharacterEncoding).    
                        end.
                        
                        when "responseContentType" then do:
                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                oParameter:DataType:ToString(), 
                                oParameter:Mode:ToString(), 
                                responseContentType).    
                        end.

                        when "responseStatus" then do:
                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                oParameter:DataType:ToString(), 
                                oParameter:Mode:ToString(), 
                                responseStatus).    
                        end.

                        otherwise do:
                            if num-entries(oParameter:name, "_") > 0
                            then do:
                                cParamType = entry(1, oParameter:name, "_").
                                case cParamType:
                                    when "qry"   
                                    then cParamValue = replace(web-context:get-cgi-value ("QUERY", trim(substr(oParameter:name, 5))), "~r~n":U, "~n":U).
                                    
                                    when "query" 
                                    then cParamValue = replace(web-context:get-cgi-value ("QUERY", substr(oParameter:name, 7)), "~r~n":U, "~n":U).
                                    
                                    when "form"  
                                    then cParamValue = replace(web-context:get-cgi-value ("FORM", substr(oParameter:name, 6)), "~r~n":U, "~n":U).
                                    
                                    otherwise cParamValue = _GetParameter(pcPathParams, oParameter:Name).                                         
                               end.
                            end.
                            else cParamValue = _GetParameter(pcPathParams, oParameter:Name).
                            
                            case oParameter:Mode:
                                when ParameterMode:Input then do:
                                    case oParameter:DataType:
                                        when DataType:Character then do:
                                            oInvokeParameters:SETPARAMETER (parametersLoop, 
                                                oParameter:DataType:ToString(), 
                                                oParameter:Mode:ToString(), 
                                                cParamValue).   
                                        end. 
                                        
                                        when DataType:Integer then do:
                                                iIntValue = integer(cParamValue) no-error.
                                                oInvokeParameters:SETPARAMETER (parametersLoop, 
                                                    oParameter:DataType:ToString(), 
                                                    oParameter:Mode:ToString(), 
                                                    iIntValue).   
                                        end. 

                                        when DataType:Int64 then do:
                                                iIntValue = int64(cParamValue) no-error.
                                                oInvokeParameters:SETPARAMETER (parametersLoop, 
                                                    oParameter:DataType:ToString(), 
                                                    oParameter:Mode:ToString(), 
                                                    iIntValue).   
                                        end. 
                                        
                                        otherwise do:
                                        undo, throw new Progress.Lang.AppError(subst("Unsupported parameter &1 '&2' as &3 in method &4:&5",
                                            oParameter:Mode:ToString(), oParameter:Name, oParameter:DataType:ToString(), cClassName, cMethodName), 200).
                                        end.
                                    end.
                                end.
                                
                                when ParameterMode:Output then do:
                                    undo, throw new Progress.Lang.AppError(subst("Unsupported output parameter name '&1' in method &2:&3",
                                                                              oParameter:Name, cClassName, cMethodName), 200).
                                end.
                                
                                otherwise do:
                                undo, throw new Progress.Lang.AppError(subst("Unsupported parameter &1 '&2' in method &3:&4",
                                    oParameter:Mode:ToString(), oParameter:Name, cClassName, cMethodName), 200).
                                end.
                            end.
                        end.
                    end case.
                end. 
                oObject = oClass:New().
                _ResetValues().
                
                do on error undo, throw:
                    oMethods[methodsLoop]:Invoke(oObject, oInvokeParameters).
                    
                    catch oRestError as bpmid.rest-mapper.RestError :
                        responseBody = _OutputRestError( oRestError ).
                        set-size(responseBodyMptr) = 0.
                        responseStatus = oRestError:responseStatus.     		
                    end catch.
                   
                    catch e as Progress.Lang.Error :
                        responseStatus = 500.
                        responseBody = _OutputRestError(new RestError(500, e)).		
                    end catch.
                end.
                _FixResponseValues().
            end.
        end.
            
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public character GetPathParam( pcUrl as char, pcName as char ):
		
		define variable result as character no-undo.

		return result.

	end method.

end class.