
&if defined(name) = 0 &then
    &scoped-define name ttUrlMap 
&endif

&if defined(scope) = 0 &then
    &scoped-define scope 
&endif

&if defined(options) = 0 &then
    &scoped-define options 
&endif

&if defined(type) = 0 &then 
    &scoped-define type temp-table
&endif

def {&scope} {&type} {&name} {&options}
    field requestUrl as char 
    field requestMethod as char
    field consumes as char
    field produces as char
    field controller as char
    field ctrlMethod as char
    field rolesRequired as char
    field requestMask as char
    field params as char
    index idxMethod requestMethod
    .