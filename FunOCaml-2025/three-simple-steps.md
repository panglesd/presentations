# The SECRET of how to achieve full-featuredness in 3 SIMPLE STEPS

{pause up}
## 1. ORGANIZATION

{include .notshowing #theroles src=roles.md}



{exec}
``` slip-script
slip.setClass(document.querySelector("#theroles"), "notshowing", false);
```


{pause up}
## 2. HYGIENE

All people working on Slipshow follow a strict hygiene of life to achieve greater efficiency:

- 5am – Waking up,
- 5:15am – Go for a footing,
- 6am – Sun salutations and stretching,
- 6:30 – Cold shower,
- 6:45 – eat vegan breakfast
- 7am – Solo Agile standup
- 8am-12pm – Pomodoro sessions with deep breathing in between
- 12pm-1pm – Fasting window (Yogi tea)
- 1pm – Squats and abs (10 reps).
- 1:30pm-5pm – Pomodoro sessions with deep breathing in between
- 5pm – No meeting

<!-- Pay to unlock. I'll make it free but you can buy my other book, How to
achieve transcendence in three simple steps -->
## 3. OCaml

Well, actually that is the main reason.

- A single language for browser and (static) native code
  - Static typing,
  - Precise compiler errors. Illustration: Add an `id` to communication message.
  - Lovely syntax

{pause up}

A new step looks like this

```ocaml
let elem = next_activated_elem () in

List.iter
  (fun action -> maybe_activate action elem)
  all_actions
```

{.block #quest}
How to go back?

```ocaml
type 'a undoable = 'a * (unit -> unit)
```

{pause up=quest}
```ocaml
# let set = (:=)
val set : 'a ref -> 'a -> unit
```

{carousel change-page}
> ```ocaml
> # let set_u x n =
>     let undo =
>       ??????
>       ??????               
>     in
>     (x := n), undo
>
> val set : 'a ref -> 'a -> unit undoable
> ```
> ```ocaml
> # let set_u x n =
>     let undo =
>       let old = !x in
>       fun () -> x := old
>     in
>     (x := n), undo
>
> val set : 'a ref -> 'a -> unit undoable
> ```

Order:

- I'm going to highlight three things that help me write software efficiently
  - Language
    - First show that many features are used:
      - ✅️ Functors
      - ✅️ First class modules for actions (show `actions.mli` ?)
      - ✅️ GADT to direct parsing.
      - ✅️ Extensible variants
      - ✅️ Polymorphic datatypes
      - ❌ Objects
      - ❌ Effects
    - Then speak about undo monad

    ```ocaml
    type 'a with_undo = { value : 'a; undo : unit -> unit }

    let set x v =
      Format.printf "Setting value from %d to %d\n%!" !x v;
      x := v

    let ( := ) x v = set x v

    let set_u x v =
      let undo =
        let old = !x in
        fun () -> x := old
      in
      let value = x := v in
      { value; undo }

    let bind (x : 'a with_undo) (f : 'a -> 'b with_undo) : 'b with_undo =
      let y = f x.value in
      let undo () =
        y.undo ();
        x.undo ()
      in
      { value = y.value; undo }

    let ( let* ) x v = bind x v
    let ( := ) v n = set_u v n
    let x = ref 0

    let { undo; _ } =
      let* () = x := 5 in
      x := 7

    let () = undo ();;

    x
    ```

  - Tooling
    - Dune vendoring
      - Show vendoring folder
    - Dune monorepo
      - Show ../ folder
    - LSP/Merlin
      - Show how 
  - Ecosystem
    - cmdliner
    - cmarkit
    - Brr and JS bindings
    - Lambdasoup

TODO: speak about undo monad
  - Many advanced features
    - Functors and First class module: actions
    - GADT: TODO
    - Extensible variants: AST and Cmarkit
    - Effects: I'm still trying
- Excellent tooling
  - Dune
    - Slipshow's build is complex
    - Vendoring is easy
    - Moving directories is easy
    - Monorepoing is easy
  - Merlin/Ocaml-lsp-server/Ocaml-eglot
  - OCamlformat

(OCaml also has disappointed me.
  * Only few choices between extra high quality libraries
  * Compilation is a bit too fast
  * Can't multiply a string and a float
  * [...])










---

<style>
#emoji {
  font-size: 10em;
}
#lock {
  padding: 20px;
  position: absolute;
  left: 500px;
  top: 400px;
  text-align: center;
  font-size: 1em;
  background: rgba(255, 255, 255, 0.75);
  border-radius: 20px;
  border: 2px solid black;
  z-index: 10;
}
.blur {
  filter: blur(10px);
}
</style>


{pause}


{#lock}
> [🔒]{#emoji}
>
> Unlock at FunOCaml 2025, \
> Warsaw, September 15-16

