---
dimension: 16:9
---

# Odoc for the beetrooter

## What `odoc` does


{pause-block}
Turns `.mli` into a website. {pause change-page="care1 ; care2"} Add links. {pause change-page="care1 ; care2"} **Compute expansions**

<style>

#container1 pre {
  margin:0;
  height:100%;
}

#container1 code {
  height:91%;
}

</style>

{style="display:flex; height:600px" children:style="width:49%;height:100%" #container1}
----
{carousel #care1}
---
```ocaml
(* example1.ml *)

val x : int
(** The most common integer *)

type tt
(** This type is twice as [t] as usual *)

val f : tt -> tt
(** [f x] applies [f] on [x]. *)
```

```ocaml
(* example2.ml *)

module M : sig
  type t

  val compare : t -> t -> int
end

val y : M.t
```

```ocaml
(* example3.ml *)

include Map.S with type key := int

module Map : module type of Map.Make (Int)
```

{carousel #care2}
---
<iframe height=100% width=100% src="ex1/_build/default/_doc/_html/ex1/Ex1/Example1/index.html"></iframe>

<iframe height=100% width=100% src="ex1/_build/default/_doc/_html/ex1/Ex1/Example2/index.html"></iframe>

<iframe height=100% width=100% src="ex1/_build/default/_doc/_html/ex1/Ex1/Example3/index.html"></iframe>

----

{pause #howdoes up}
# How `odoc` does

![](model.draw){#model}

{draw=model}

{draw=model}

{draw=model}

{draw=model}

{draw=model}

{draw=model}

{draw=model}

<style>
#tozoom {
  position: absolute;
  width:750px;
  top:1400px;
  left: 400px;
  height:300px;
}
</style>

{draw=model}

{draw=model}

{draw=model}

{draw=model}

{draw=model}

{#tozoom focus}

{draw=model}

{draw=model}

{unfocus}

{draw=model}

{draw=model}

{draw=model}


<!--
What should I present about odoc?

- What it does
  - Turns mli into websites
  - Add links
  - But more than that! Compute expansions.
- References can be cyclic
- How it works internally
  - Stages:
    - Loading (and parsing)
    - Compiling
    - Linking
    - Generating a document
    - Outputting HTML/Latex/Manpage
- Deep dive inside the codebase
- Going further:
  - Render source code
  - Odoc theme
  - Hierarchy
  - Global sidebar
  - Cross-package references
  - Example: Support for new versions
  - Example: adding admonitions
  - Driving odoc
- More on compiling and linking
-->

{style=margin-top:1400px down}
# Driving `odoc`

![](driving.draw){#driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}

{draw=driving}


{up pause}
# Going further

What do you want to talk about?

- Render source code

- Odoc theme

- Hierarchy

- Global sidebar

- Cross-package references

- Example: Support for new versions

- Example: adding admonitions

- Driving odoc
