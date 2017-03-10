 
 /*------------------------------------------------------------------------
    File        : UrlMapper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Tue Jun 21 20:01:15 EEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Net.*.
using OpenEdge.Net.HTTP.*.

using bpmid.rest-mapper.*.
using OpenEdge.Web.IWebRequest.

block-level on error undo, throw.

class bpmid.rest-mapper.UrlMapper: 

    {bpmid/rest-mapper/ttUrlMap.i &name=ttUrlMapOrig &scope=private &options=no-undo &type=temp-table}
    
    def temp-table ttMapForLoad no-undo like ttUrlMapOrig.
    def temp-table ttUrlMap no-undo like ttUrlMapOrig
        field urlLength as int
        .
    def temp-table ttRating no-undo like ttUrlMap
        field rating as int
        index idxRating rating desc urlLength desc.

	define static protected property singletonObject as UrlMapper no-undo 
	get.
	set. 

	define public property WEB_APP_PATH as character no-undo 
	get.
	set. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _GetPathParams( pcTemplate as char, pcUrl as char ):
		
		def var cTemplate as char no-undo.
		def var cPath as char no-undo.
		def var cQuery as char no-undo.
		def var cResult as char no-undo.
        def var i as int no-undo.
        def var cName as char no-undo.
        def var cValue as char no-undo.
        def var lFirst as log no-undo init true.
        
        cTemplate = _RemoveQueryString(pcTemplate) + "/".
        
        i = index(pcUrl, "?").
        if i = 0
        then cPath = pcUrl.
        else do:
            cPath = substr(pcUrl, 1, max(1, i - 1)).
            cQuery = substr(pcUrl, i + 1).
        end.
        cPath = cPath + "/".
        
        do i = 1 to min(num-entries(pcTemplate, "/"), num-entries(cPath, "/")).
            cName = entry(i, pcTemplate, "/").
            cValue = entry(i, cPath, "/").
            
            if cName <> cValue
            then do:
                cName = substr(cName, 2, length(cName) - 2).
                if lFirst
                then do: 
                    lFirst = false.
                    cResult = subst("&1=&2", cName, cValue).
                end.
                else cResult = cResult + "&" + subst("&1=&2", cName, cValue).
            end.
        end. 		
        if cQuery > ""
        then do:
            if lFirst
            then cResult = cQuery.
            else cResult = cResult + "&" + cQuery.
        end.
		return cResult.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _GetUrlMask( cUrl as char ):
		def var i as int no-undo.
		def var cMask as char no-undo.
		def var cS as char no-undo.
		def var lWildCardMode as log no-undo.
		
        do i = 1 to length(cUrl):
            cS = substr(cUrl, i, 1).
            if lWildCardMode
            then do:
                if cS = "}"
                then lWildCardMode = false.
            end.
            else do:
                if cS = "~{"
                then do:
                    lWildCardMode = true.
                    cMask = cMask + "*".
                end.
                else cMask = cMask + cS.
            end.
        end.
        
		return cMask.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _GetWorkUrl( pcUrl as char ):
        
        pcUrl = _RemoveQueryString(pcUrl).
        pcUrl = _RemoveTrailingSlash(pcUrl).
        pcUrl = _RemoveAgentPath(pcUrl).
        
        return pcUrl.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private void _InitializeUrlMappingFields(  ):
	    def buffer bUrlMap for ttUrlMap.
	    def var cMethod as char extent 4 init ["GET", "POST", "PUT", "DELETE"].
	    def var i as int no-undo.
	    
        for each ttUrlMap:
            ttUrlMap.requestMask = _GetUrlMask(ttUrlMap.requestUrl).
            ttUrlMap.urlLength = length(ttUrlMap.requestMask).
            ttUrlMap.requestMask = _RemoveTrailingSlash(ttUrlMap.requestMask).
            
            if ttUrlMap.requestMethod > ""
            then do:
                if not can-find(first bUrlMap where bUrlMap.requestUrl=ttUrlMap.requestUrl and bUrlMap.requestMethod = ttUrlMap.requestMethod)
                then do:
                    create bUrlMap.
                    buffer-copy ttUrlMap to bUrlMap.
                end.
            end.
            else do:
                do i = 1 to 4:
                    if not can-find(first bUrlMap where bUrlMap.requestUrl=ttUrlMap.requestUrl and bUrlMap.requestMethod = cMethod[i])
                    then do:
                        create bUrlMap.
                        buffer-copy ttUrlMap to bUrlMap
                            assign bUrlMap.requestMethod = cMethod[i].
                    end.
                end.
            end.
        end.
        
        for each ttUrlMap where ttUrlMap.requestMethod = "":
            delete ttUrlMap.
        end.
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _RemoveAgentPath( pcUrl as char ):
		
		def var i as int no-undo.
		def var cUrl as char no-undo.

        cUrl = pcUrl.		
		i = index(pcUrl, "WService=").
		if i > 0
		then do:
		    cUrl = substr(pcUrl, i).
		    i = index(cUrl, "/").
		    if i > 0
		    then cUrl = substr(cUrl, i).
		end.

		return cUrl.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _RemoveQueryString( cUrl as char ):
		
		def var i as int no-undo.
		i = index(cUrl, "?").
		if i = 0
		then return cUrl.
		else return substr(cUrl, 1, max(1, i - 1)).

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private character _RemoveTrailingSlash( cUrl as char ):
		
		if substr(cUrl, length(cUrl)) = "/"
		then return substr(cUrl, 1, length(cUrl) - 1).
		else return cUrl.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public static bpmid.rest-mapper.UrlMapper Factory(  ):
		
        if UrlMapper:singletonObject = ?
        then do:
            UrlMapper:singletonObject = new UrlMapper().
        end.
        else return UrlMapper:singletonObject.

	end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    method public logical FindRequestExecutor( poRequest as IWebRequest, output pcClassName as char, output pcMethodName as char, output pcPathParams as char, output pcRolesRequired as char):
        
        def var cUrl as char no-undo.
        def var cMethod as char no-undo.
        def var cConsumes as char no-undo.
        def var cAccept as char no-undo.
        def var oAcceptHeader as HttpHeader no-undo.
        
        cUrl = _GetWorkUrl(poRequest:PathInfo).
        
        message subst("WorkUrl=&1  mainUrl=&2", cUrl, _RemoveAgentPath(poRequest:PathInfo)).
        
        cMethod = poRequest:Method.
        cConsumes = poRequest:ContentType.
        oAcceptHeader = poRequest:getHeader("Accept").
        
        if oAcceptHeader <> ? 
        then cAccept = oAcceptHeader:Value.
        
        empty temp-table ttRating.
        
        for each ttUrlMap where ttUrlMap.requestMethod = cMethod and can-do(ttUrlMap.requestMask, cUrl):
            message subst("&1 &2", ttUrlMap.requestMask, cUrl).
            create ttRating.
            buffer-copy ttUrlMap to ttRating.
            
            if cConsumes = ttUrlMap.consumes
            then ttRating.rating = ttRating.rating + 1.
            
            if cAccept > "" and cAccept = ttUrlMap.produces
            then ttRating.rating = ttRating.rating + 1.
        end.
        
        find first ttRating use-index idxRating no-error.
        if available ttRating
        then do:
            pcClassName = ttRating.controller.
            pcMethodName = ttRating.ctrlMethod.
            pcPathParams = _GetPathParams(ttRating.requestUrl, _RemoveAgentPath(poRequest:PathInfo)).
            pcRolesRequired = ttRating.rolesRequired.
            return true.
        end.
        
        pcClassName = ?.
        pcMethodName = ?.
        pcPathParams = ?.
        return false.
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public character GetMappingTable(  ):
		
		define variable result as character no-undo.
        result = "Loaded URL mappings:~n".
        for each ttUrlMap:
            result = result + subst("&1 - &2 - &3 - &4:&5 (&6)~n", ttUrlMap.requestUrl, ttUrlMap.requestMethod, ttUrlMap.rolesRequired, ttUrlMap.controller, ttUrlMap.ctrlMethod, ttUrlMap.requestMask).
        end.    
        result = result + "End of URL mappings~n".

		return result.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void LoadUrlMappingsFromFile( cFileName as char ):
        def var cMappingFile as char no-undo.
        def var cRow         as char no-undo.
    
        cMappingFile = search(cFileName).
        if cMappingFile > ""
        then do:
            input from value(cMappingFile).
            import unformatted cRow.
            repeat:
                create ttUrlMap.
                import delimiter "~t" ttUrlMap.
            end.
            input close.
            for each ttUrlMap where ttUrlMap.requestUrl = "":
                delete ttUrlMap.
            end.
        end.
        else undo, throw new Progress.Lang.AppError(subst("URL mapping file &1 was not found!", cFileName), 200).		
        
        _InitializeUrlMappingFields().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method public void LoadUrlMappingsFromTable( input table ttMapForLoad ):
		
		for each ttUrlMap: delete ttUrlMap. end.
		
		for each ttMapForLoad:
		    create ttUrlMap.
		    buffer-copy ttMapForLoad to ttUrlMap.
	    end.
		
		_InitializeUrlMappingFields().
		return.

	end method.

end class.