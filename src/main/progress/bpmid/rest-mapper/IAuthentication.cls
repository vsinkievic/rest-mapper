
/*------------------------------------------------------------------------
    File        : IAuthentication
    Purpose     : To hold web user authentication and assigned roles
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Fri Mar 29 12:44:34 EET 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface bpmid.rest-mapper.IAuthentication:  
    
    /*------------------------------------------------------------------------------
     Purpose: Login name of the authenticated user.
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY loginName AS CHARACTER NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
     Purpose: Language of the user interface.
     Notes:
    ------------------------------------------------------------------------------*/
    define public property lang as character no-undo 
    get.

    /*------------------------------------------------------------------------------
     Purpose: ID of office where authenticated user works
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY offId AS INTEGER NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
     Purpose:  ID of parther of the authenticated user. 
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY prtId AS INTEGER NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
     Purpose:  ID of warrant which grants authenticated user to work with the system
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY wrnId AS INTEGER NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
     Purpose: Check if authenticated user can work in the office asked.
     Notes:
    ------------------------------------------------------------------------------*/
    method public logical canWorkInOffice( piOfficeId as integer ). 

    /*------------------------------------------------------------------------------
     Purpose:  Check if authenticated user has access to the parther object 
     Notes:
    ------------------------------------------------------------------------------*/
    method public logical hasAccessToPartnerObject( piObjectPartnerId as int64 ). 

    /*------------------------------------------------------------------------------
     Purpose:  Check if authenticated user has any of the roles
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL hasAnyRole( pcRoleList as char ).
    
    /*------------------------------------------------------------------------------
     Purpose:  Check if authenticated user has role asked
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL hasRole( pcRoleName as char ).

end interface.