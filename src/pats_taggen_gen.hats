abstype
tagent_type = ptr
typedef
tagent = tagent_type

//
//
fun
tagent_new(a0: symbol, a1: location): tagent
fun
tagent_sym(x: tagent): symbol
overload .tagent_sym with tagent_sym
fun
tagent_loc(x: tagent): location
overload .tagent_loc with tagent_loc
//
