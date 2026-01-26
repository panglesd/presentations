# La monade annulation dans Slipshow

{.block #next2}
La fonction `next` retourne une fonction pour annuler le reste des effets de bords.

Utilisons le patron de conceptions des monades pour représenter un calcul que l'on peut annuler. Il nous faut définir un type, et comment chaîner deux calculs.

{pause}

```ocaml
type 'a t = {
  value : 'a;
  undo : unit -> unit
}
```

{pause}

```
r1 := calcul1 ;
calcul2
```

![](undo-monad-enfin.draw){#umed}

{draw=umed}

{draw=umed}

{draw=umed}

{pause down}
```ocaml

let return ?(undo = fun () -> ()) value = {value ; undo}

let bind x f =
  let undo1 = x.undo1 in
  let c = f x.value in
  let undo2 = c.undo in
  let undo () = undo2 (); undo1 () in
  return ~undo c.value
```

{draw=umed}

{pause up}
On ajoute aussi des primitives:

```
let set_ref (x : 'a ref) (v : 'a) : 'a ref -> 'a -> unit t =
  let old_value = !x in
  let undo () = x := old_value in
  return ~undo (x := v)
```

Et voila!

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

{draw=umed}

{pause up}
## Et dans Slipshow?

```ocaml
let next window () =
  find_next_pause_or_step () |>
  Option.map @@ fun pause ->
  let> () = Actions.exit window pause in
  let> () = AttributeActions.do_ window pause in
  Undoable.return ()
```

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

{draw=umed}

{pause up}
# Aller plus loin

- Les utilisateurs peuvent enregistrer leur undo custom quand les "fonctions de
  base" proposées ne suffisent pas.

- Dans la vrai vie, on utilise aussi une monade IO et (surtout) une monade
  Promesse pour que les actions (et les undos) prennent du temps.
