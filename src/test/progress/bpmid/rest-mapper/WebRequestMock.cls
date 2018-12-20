 
 /*------------------------------------------------------------------------
    File        : WebRequestMock
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Fri Jun 24 10:21:02 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Web.IWebRequest.
using bpmid.rest-mapper.*.
using OpenEdge.Core.Collections.*.

block-level on error undo, throw.

class bpmid.rest-mapper.WebRequestMock implements IWebRequest: 
    def temp-table ttHeader no-undo
        field headerName as char
        field obj as Object
        .

	define public property CharacterEncoding as character no-undo 
	get.
	set. 

	define public property ContentLength as integer no-undo 
	get.
	set. 

	define public property ContentMD5 as raw no-undo 
	get.
	set. 

	define public property ContentType as character no-undo 
	get.
	set. 

	define public property ContextNames as character no-undo 
	get.
	set. 

	define public property DefaultCookieDomain as character no-undo 
	get.
	set. 

	define public property DefaultCookiePath as character no-undo 
	get.
	set. 

	define public property Entity as Progress.Lang.Object no-undo 
	get.
	set. 

	define public property LocalAddress as character no-undo 
	get.
	set. 

	define public property LocalHost as character no-undo 
	get.
	set. 

	define public property LocalPort as integer no-undo 
	get.
	set. 

	define public property Method as character no-undo 
	get.
	set. 

	define public property PathInfo as character no-undo 
	get :
	    
	    if this-object:URI = ?
	    then return "".
	    def var cPath as char no-undo.
	    def var i as int no-undo.
	    cPath = this-object:URI:ToString().
	    i = index(cPath, "/WService").
	    if i > 0
	    then do:
	       cPath = substr(cPath, i + 1).
	       cPath = substr(cPath, index(cPath, "/")).
	       if r-index(cPath, "/") = length(cPath)
	       then cPath = substr(cPath, 1, length(cPath) - 1).
	    end.
	    return cPath.
	end.
	set. 

	define public property PathParameterNames as character no-undo 
	get.
	set. 

	define public property RemoteAddress as character no-undo 
	get.
	set. 

	define public property RemoteHost as character no-undo 
	get.
	set. 

	define public property RemotePort as integer no-undo 
	get.
	set. 

	define public property RemoteUser as character no-undo 
	get.
	set. 

	define public property ResolvedTransportPath as character no-undo 
	get.
	set. 

    define public property ResolvedWebAppPath as character no-undo 
    get.
    private set. 
     

	define public property ServerSoftware as character no-undo 
	get.
	set. 

	define public property TransferEncoding as character no-undo 
	get.
	set. 

	define public property TransportPath as character no-undo 
	get.
	set. 

	define public property URI as OpenEdge.Net.URI no-undo 
	get.
	set. 

	define public property UriTemplate as character no-undo 
	get.
	set.

	define public property Version as character no-undo 
	get.
	set. 

	define public property WebAppPath as character no-undo 
	get.
	set. 

	method public void ClearCookies(  ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public void ClearHeaders(  ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public longchar GetContextValue( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public OpenEdge.Net.HTTP.Cookie GetCookie( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public integer GetCookies( output poCookies as OpenEdge.Net.HTTP.Cookie extent ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public OpenEdge.Net.HTTP.HttpHeader GetHeader( input pcName as character ):
		
		find first ttHeader where ttHeader.headerName = pcName no-error.
		if not available ttHeader then return ?.
		
        return cast(ttHeader.obj, OpenEdge.Net.HTTP.HttpHeader).

	end method.

	method public integer GetHeaders( output poHeaders as OpenEdge.Net.HTTP.HttpHeader extent ):
		
		def var i as int no-undo.
		for each ttHeader:
		    i = i + 1.
		end.
		
		extent(poHeaders) = i.
		do i = 1 to extent(poHeaders):
		  poHeaders[i] = cast(ttHeader.obj, OpenEdge.Net.HTTP.HttpHeader).
		end.

	end method.

	method public character GetPathParameter( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public logical HasCookie( input poCookie as OpenEdge.Net.HTTP.Cookie ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public logical HasCookie( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public logical HasHeader( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public void RemoveCookie( input poCookie as OpenEdge.Net.HTTP.Cookie ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public void RemoveCookie( input pcName as character ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

	method public void RemoveHeader( input pcName as character ):
		 
		find first ttHeader where ttHeader.headerName = pcName no-error.
		if available ttHeader
		then delete ttHeader.

	end method.

	method public void SetCookie( input poCookie as OpenEdge.Net.HTTP.Cookie ):
		
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

	end method.

    method public void SetCookies( input poCookies as OpenEdge.Net.HTTP.Cookie extent ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

	method public void SetHeader( input poHeader as OpenEdge.Net.HTTP.HttpHeader ):
		
		if poHeader = ?
		then next.
		
		find ttHeader where ttHeader.headerName = poHeader:Name no-error.
		if not available ttHeader
		then do:
		    create ttHeader.
		    ttHeader.headerName = poHeader:Name.
		end. 
		ttHeader.obj = poHeader.

	end method.

    method public void SetHeaders( input poHeader as OpenEdge.Net.HTTP.HttpHeader extent ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

end class.