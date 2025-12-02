# The Undo Monad

![](undomonad.draw){#undomonaddraw draw}

{draw=undomonaddraw}


{up style="margin-top:1000px" pause}
We want to encode **revertible computations with side effects**.

```ocaml
type 'a t = {
  value : 'a;
  undo : unit -> unit;
}
```


{draw=undomonaddraw}

{pause}
```ocaml
let return undo value = {undo; value}
```

{pause down}
```ocaml
let bind computation1 f =
  let computation2 = f computation1.value in
  let value = computation2.value in
  let undo =
    computation2.undo ();
    computation1.undo ()
  in
  {undo; value}
```

{draw=undomonaddraw}

