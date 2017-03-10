 
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
using OpenEdge.Net.HTTP.*.
using bfv.spring4oe.beans.factory.*.

block-level on error undo, throw.

class bpmid.rest-mapper.WebRequestExecutor: 

    def private var mcClassName as char no-undo.
    def private var mcMethodName as char no-undo.
    def private var mcHostUrl as char no-undo. // HOST_URL? 
    def private var mcAppUrl as char no-undo. // SCRIPT_NAME
    def private var mcSelfUrl as char no-undo. // REQUEST_URI arba SCRIPT_URL
    def private var mcHttpHost as char no-undo. // domain line www.lateko.lt
    def private var mlPersistenVarsInitialized as log no-undo.
    
	define public property responseCookie as Cookie no-undo 
	get.
	private set. 

    define public property responseCookies as CookieCollection no-undo 
    get.
    private set. 

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

	method private character _fixParamValue( pcValue as char ):
		def var cFixedValue as char no-undo.
		
		cFixedValue = replace(pcValue, "~r~n":U, "~n":U).
		cFixedValue = codepage-convert(cFixedValue, session:cpinternal, "utf-8").

		return cFixedValue.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _getCgiValue( pcEnv as char, pcParam as char ):
		
		if session:client-type = "WEBSPEED"
        then return web-context:get-cgi-value(pcEnv, pcParam).
        else return ?. 

	end method.

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

	method private void _initPersistentVariables(  ):
		if mlPersistenVarsInitialized
		then return.

        if session:client-type = "WEBSPEED"
        then do:
            mcHostUrl  = web-context:get-cgi-value("env", "HOST_URL"). 
            mcAppUrl   = web-context:get-cgi-value("env", "SCRIPT_NAME").
            mcSelfUrl  = web-context:get-cgi-value("env", "REQUEST_URI"). // arba SCRIPT_URL
    		mcHttpHost = web-context:get-cgi-value("env", "HTTP_HOST").
		end.

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
		
		if cExpectedDataType <> oParameter:DataType:ToString() and oParameter:DataType:ToString() <> "Object" 
		then undo, throw new Progress.Lang.AppError(subst("&1 datatype should be &2 in &3:&4 (current type: &5)", oParameter:Name, cExpectedDataType, mcClassName, mcMethodName, oParameter:DataType:ToString()), 299).
 
        if cExpectedMode <> oParameter:Mode:ToString()
        then undo, throw new Progress.Lang.AppError(subst("&1 mode should be &2 in &3:&4 (current mode: &5)", oParameter:Name, cExpectedMode, mcClassName, mcMethodName, oParameter:Mode:ToString()), 298).

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
		
        return subst('~{ "err": "&1", "msg": "&2", "message": "&2", "path": "&3" ~}', 
                        oRestError:err, oRestError:msg, _getCgiValue("env", "REQUEST_URI")).

	end method.


    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method private longchar _OutputRestErrorAsHtml( oRestError as RestError ):
        
        return subst('<html><body><h1>&1</h1><p>&2</p></body></html>', 
                    oRestError:err, oRestError:msg, _getCgiValue("env", "REQUEST_URI")).

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
		delete object (responseCookie) no-error.
		delete object (responseCookies) no-error.
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
        
        define variable lIsBean as logical no-undo.
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

        _initPersistentVariables().
        
        mcClassName = cClassName.
        mcMethodName = cMethodName.
        
        if cClassName begins "bean:"
        then do:
           lIsBean = true.
           cClassName = substr(cClassName, 6). 
           oObject = XmlBeanFactory:DefaultFactory:GetBean(cClassName).
           oClass = oObject:GetClass().
           cClassName = oClass:TypeName.
        end.
        else do:
            oClass = Class:GetClass(cClassName).
            oObject = oClass:New().
        end.
        
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
                        when "app_url" or when "appUrl"then do:
                            _IsParameterValid(oParameter, "CHARACTER", "INPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "CHARACTER", "INPUT", mcAppUrl).    
                        end.

                        when "host_domain" or when "HTTP_HOST" then do:
                            _IsParameterValid(oParameter, "CHARACTER", "INPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "CHARACTER", "INPUT", mcHttpHost).    
                        end.
                        
                        when "host_url" or when "hostUrl"then do:
                            _IsParameterValid(oParameter, "CHARACTER", "INPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "CHARACTER", "INPUT", mcHostUrl).    
                        end.

                        when "requestCookie" then do:
                            _IsParameterValid(oParameter, "CHARACTER", "INPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "CHARACTER", "INPUT", _getCgiValue("ENV":U, "HTTP_COOKIE")).    
                        end.

                        when "responseCookie" then do:
                            _IsParameterValid(oParameter, "OpenEdge.Net.HTTP.Cookie", "OUTPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "OpenEdge.Net.HTTP.Cookie", "OUTPUT", responseCookie).    
                        end.
                        
                        when "responseCookies" then do:
                            _IsParameterValid(oParameter, "OpenEdge.Net.HTTP.CookieCollection", "OUTPUT").
                            oInvokeParameters:SETPARAMETER (parametersLoop, "OpenEdge.Net.HTTP.CookieCollection", "OUTPUT", responseCookies).    
                        end.
                        
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
                                    then cParamValue = _fixParamValue(_getCgiValue("QUERY", trim(substr(oParameter:name, 5)))).
                                    
                                    when "query" 
                                    then cParamValue = _fixParamValue(_getCgiValue("QUERY", substr(oParameter:name, 7))).
                                    
                                    when "form"  
                                    then cParamValue = _fixParamValue(_getCgiValue("FORM", substr(oParameter:name, 6))).
                                    
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
                
                _ResetValues().
                
                do on error undo, throw:
                    oMethods[methodsLoop]:Invoke(oObject, oInvokeParameters).
                    
                    catch oRestError as bpmid.rest-mapper.RestError :
                        responseBody = _OutputRestError( oRestError ).
                        set-size(responseBodyMptr) = 0.
                        responseStatus = oRestError:responseStatus.     		
                    end catch.
                   
                    catch ae as Progress.Lang.AppError :
                        message subst("&1:&2 ERROR: &3: &4 &5", cClassName, cMethodName, ae:GetClass():TypeName, ae:GetMessage(1), ae:ReturnValue).
                        if ae:CallStack > "" then message ae:CallStack.
                        responseStatus = 500.
                        responseBody = _OutputRestError(new RestError(500, ae)).     
                    end catch.

                    catch e as Progress.Lang.Error :
                        message subst("&1:&2 ERROR: &3: &4 &5", cClassName, cMethodName, e:GetClass():TypeName, e:GetMessage(1)).
                        if e:CallStack > "" then message e:CallStack.
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