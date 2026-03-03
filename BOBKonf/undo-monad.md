# The Undo Monad in Slipshow

{.block #next2}
The `next` function returns a way to undo all side-effects

We are going to use the "Monad" design pattern to represent "**computations that outputs an undo function**".

{pause}

We need:

- A type

- "Entry-point" computations

- Chaining computations

{pause #a-type}
## A type

```ocaml
type 'a computation = {
  result : 'a;
  undo : unit -> unit
}
```

{pause up=a-type}

## Entry-point computations

**Example**: Setting whether a class is given to an element -- in an undoable way.

{carousel change-page=~n:all}
> ```ocaml
> let set_ref x new_val =
>   let undo =
>                                   
>                                   
>   in
>   let result = x := new_val in
>   {result ; undo}
> ```
> ```ocaml
> let set_ref x new_val =
>   let undo =
>                                  
>               x := old_val
>   in
>   let result = x := new_val in
>   {result ; undo}
> ```
> ```ocaml
> let set_ref x new_val =
>   let undo =
>     let old_val = !x in
>     fun () -> x := old_val
>   in
>   let result = x := new_val in
>   {result ; undo}
> ```


{pause up}
## Chaining computations

{.pseudo-code}
```
r1 := computation1 ;
computation2
```

<!-- ![](undo-monad-enfin.draw){#umed} -->

<!-- {draw=umed} -->

<!-- {draw=umed} -->

<!-- {draw=umed} -->

{pause down}
```ocaml
let bind x f =
  let c = f x.value in
  let undo () = c.undo (); x.undo () in
  {value = c.value; undo = undo}
```

{draw=umed}

{pause up}
```ocaml
let x = ref 0

let test =
  let* () = set_ref x (!x + 1) in
  let* () = set_ref x (!x + 1) in
  return !x ;;

!x ;;
test.undo ();;
!x ;;
```

{pause focus="ss1ex ss2ex tex" #tex}
## The Undo monad in Slipshow?

{#ss1ex}
```ocaml
let next window () =
  find_next_pause_or_step () |>
  Option.map @@ fun pause ->
  let> () = Actions.exit window pause in
  let> () = AttributeActions.do_ window pause in
  Undoable.return ()
```

{#ss2ex}
```ocaml
let exit window to_elem =
  let rec exit () =
    let coord = Undoable.Stack.peek Enter.stack in
    match coord with
    | None -> Undoable.return ()
    | Some { element_entered; _ }
      when Brr.El.contains element_entered ~child:to_elem ->
        Undoable.return ()
    | Some { coord_left; duration; _ } -> (
        let duration = Option.value duration ~default:1.0 in
        let> _ = Undoable.Stack.pop_opt Enter.stack in
        match Undoable.Stack.peek Enter.stack with
        | None -> Universe.Move.move window coord_left ~duration
        | Some { Enter.element_entered; _ }
          when Brr.El.contains element_entered ~child:to_elem ->
            let duration =
              match Brr.El.at (Jstr.v "enter-at-unpause") to_elem with
              | None -> duration
              | Some s -> (
                  match Enter.parse_args to_elem (Jstr.to_string s) with
                  | Error _ -> duration
                  | Ok v -> Option.value ~default:duration v.duration)
            in
            Universe.Move.move window coord_left ~duration
        | Some _ -> exit ())
  in
  exit ()
```

{unfocus pause up}
# Going further

In real life, the type is more complex!

{carousel .carousel-fixed-size change-page="~n:all"}
----

```ocaml
type 'a computation = {
  result : 'a;
  undo : unit -> unit
}
```

```ocaml
type 'a result = {
  result : 'a;
  undo : unit -> unit
}

type 'a computation = 'a result io
```

```ocaml
type 'a result = {
  result : 'a;
  undo : unit -> unit
}

type 'a computation = 'a result promise io
```

----

{pause up}

This way of solving the problem works well with custom scripts.

````markdown
{exec}
```slip-script
document
 .querySelectorAll
  (".c")
 .forEach(
    slip.reveal
 )
```
````

{pause}

````markdown
{exec}
```slip-script
ThreeJS.startAnimation()
slip.onUndo(() => { ThreeJS.rewindAnimation() })
```
````
