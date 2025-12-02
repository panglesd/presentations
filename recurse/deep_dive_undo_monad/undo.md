# The Undo Monad

We want to encode **revertible computations with side effects**.

```ocaml
type 'a t = {
  value : 'a;
  undo : unit -> unit;
}
```
