abstype
tree_type = ptr
typedef
tree = tree_type

//
datavtype
tree_view =
  | TREEnil of ()
  | TREEcons of (tree, int, tree)
//
fun
tree_encode(v: tree_view): tree
fun
tree_view(x: tree): tree_view
fun
tree_view_free(v: tree_view): void
fun
tree_tag(x: tree): int
fun
tree_TREEnil(): tree
fun
tree_TREEcons(a0: tree, a1: int, a2: tree): tree
fun
tree_is_TREEnil(x: tree): bool
fun
tree_is_TREEcons(x: tree): bool
//
