# The world after Odoc 3

{pause}

<style>
#box1 {
  position: absolute;
  width: 420px;
  height: 450px;
  top: 210px;
}
#box2 {
  position: absolute;
  width: 950px;
  height: 450px;
  top: 210px;
  left:387px;
}
code {
  background: lightgrey;
  padding-top: 3px;
  padding-left: 3px;
}
pre {
  background: lightgrey;
}
.two_elems > * {
  width: 50%
}
.three_elems > * {
  width: 33%
}
.notification {
  font-size: 1.1em;
  line-height: 43px;
  position: fixed;
  top: 10px;
  border: 2px solid black;
  right:-1480px;
  width: 1440px;
  background: bisque;
  padding: 10px;
  padding-top: 10px;
  border-radius: 10px;
  transition: all 0.75s;
}
.notification.active {
  right:20px;
}
.notification.active.dismissed {
display: none;
}
.notification img {
  float:left;
  height:100px;
  margin-right: 10px;
}
.youneedto {
  color: blue;
  font-size: 0.8em
}
</style>

{.notification slipshow-ui #riku}
> ![](riku.png) Hello Paul-Elliot ! I'm sorry to interrupt your talk but you should create proposals in order to do community work. **Could you create a proposal for your talk?**


{.notification slipshow-ui #leandro}
![](leandro.png) Hello Paul-Elliot! Sorry to interrupt your talk, but could you add metrics to measure the impact of your presentation? I'm available to help!

{.notification slipshow-ui #jules}
![](jules.png) Yo ! Ça te tente un coffee-chat ?

{.notification slipshow-ui #jon}
![](jon.png) Hi Paul-Elliot! That reminds me: could you review my [+19242]{style="color:green"},[-454]{style="color:red"} lines WIP commit?

{.notification slipshow-ui #lyrm}
> ![](lyrm.png) Salut Paul-Elliot ! Comment vas-tu ? Dis, ça te dirait de parler d'Argos dans ta présentation ? Vu que t'as travaillé dessus...

{.notification slipshow-ui #sabine}
> ![](sabine.png) Hello Paul-Elliot! I'm sorry, I think speaking about Argos will disturb the talk about odoc. Could you not do it?

{.notification slipshow-ui #nathalie}
> ![](nathalie.png) Salut Chéri ! <br> On se voit ce soir ? 💘❤️‍🔥


{.block}
In March 2025, the face of the world changed: `odoc.3.0.0` was released.

- Added hierarchy to documentation,   [$\leftarrow$ you need to **specify your hierarchy**]{.unrevealed .youneedto style="margin-left: 220px"}

- Added medias (images, audios, ...) and assets, [$\leftarrow$ you need to **specify your media files**]{.unrevealed .youneedto style="margin-left: 60px"}

- Added cross-package links [$\leftarrow$ you need to **specify your dependencies**]{.unrevealed .youneedto style="margin-left: 327px"}

- Added source rendering [$\leftarrow$ you need to **update the build system**]{.unrevealed .youneedto style="margin-left: 365px"}

{pause exec-at-unpause=reveal-tooling}


{#reveal-tooling}
```slip-script
document.querySelectorAll(".youneedto").forEach((e)=> slip.setClass(e, "unrevealed", false));
```

**Actually not available: Locked behind tooling**

- `dune build @doc` did not enable the new features,

- `ocaml.org` did not enable the new features. {pause}

{.block}
The face of the world changed, but **not much has changed** for the average ocamleer.

{style="text-align: center; font-size: 2em" #wtd}
So, what to do?

{style="display: flex" .two_elems #container pause up=wtd}
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#riku"), "active", true)
> ```
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#riku"), "dismissed", true)
> ```
>
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#jules"), "active", true)
> ```
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#jules"), "dismissed", true)
> ```
>
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#nathalie"), "active", true)
> ```
>
> {exec-at-unpause}
> ```slip-script
> slip.setClass(document.querySelector("#nathalie"), "dismissed", true)
> ```
>
>
>
> {slip}
> > # ![](dune_logo.png){height=100px style="padding-right: 8px;vertical-align: -5px;"} and [odoc 3]{style="font-size:2em"}
> >
> > {#specify}
> > ## 1. Specify
> >
> > ### Offer new stanza options for referencing other packages
> >
> > {.unrevealed reveal-at-unpause}
> > > ```
> > > (package
> > >   (depends ...)
> > >   (documentation
> > >     (depends ...))
> > > ```
> > >
> > {#offer-new-stanza}
> > ### Offer new stanza options for assets and hierarchical documentation
> >
> > {exec-at-unpause}
> > ```slip-script
> > slip.setClass(document.querySelector("#leandro"), "active", true)
> > ```
> >
> > {exec-at-unpause}
> > ```slip-script
> > slip.setClass(document.querySelector("#leandro"), "dismissed", true)
> > ```
> >
> > {.unrevealed reveal-at-unpause up=specify}
> > > Before:
> > > ```txt
> > > (documentation
> > >   (mld_files <list of .mld files>))
> > > ```
> > > {.unrevealed reveal-at-unpause #afterdune}
> > > > After:
> > > > ```txt
> > > > (documentation
> > > >   (files <files and hierarchy target>))
> > > >            ; the stanza above includes assets / hierarchy
> > > > ```
> > > {.unstatic static-at-unpause up=afterdune #examples-dune}
> > > > #### Examples
> > > > ```
> > > > (documentation
> > > >  (files
> > > >   (glob_files *.mld)         ; Include mld files
> > > >   (glob_files *.png)))       ; and png images
> > > > ```
> > > > 
> > > > ```
> > > > (documentation
> > > >  (files
> > > >   (glob_files_rec            ; Include `doc/`, keep hierarchical
> > > >    (doc/* with_prefix .))))  ; structure for documentation
> > > > ```
> > > >
> > > {.unrevealed reveal-at-unpause #lastduneex}
> > > > ```
> > > > doc/index.mld            ->  <pkg doc root>/index.html
> > > > doc/tuto/index.mld       ->  <pkg doc root>/tuto/index.html
> > > > doc/tuto/tutorial1.mld   ->  <pkg doc root>/tuto/tutorial1.html
> > > > ```
> >
> > {up=lastduneex}
> > ## 2. Respect the specification
> >
> > ### Install files for odig/ocaml.org's driver
> >
> > {.unrevealed reveal-at-unpause}
> > > Odoc 3 defines a convention for of **opam-installed packages**.
> > >
> > > Dune needs to respect the convention given the user input.
> > >
> > > {.unrevealed reveal-at-unpause}
> > > ```
> > > doc/index.mld        ->   <switch>/doc/<pkgname>/index.mld
> > > doc/tuto/index.mld   ->   <switch>/doc/<pkgname>/tuto/index.mld
> > > doc/tuto/tuto1.mld   ->   <switch>/doc/<pkgname>/tuto/tuto1.mld
> > > ```
> > ### Rewrite the "dune rules" to build documentation with the new CLI
> >
> > {.unrevealed reveal-at-unpause}
> > ```bash
> > $ odoc compile --parent-id <pkgname>/tuto/ tutorial1.mld
> > ```
> >
> > {.unrevealed reveal-at-unpause}
> > > That looked a bit complicated [$\rightarrow$]{style="padding-left:15px;padding-right:15px;"}
> > > **Jon will take care of it.**
> >
> > {exec-at-unpause}
> > ```slip-script
> > slip.setClass(document.querySelector("#jon"), "active", true)
> > ```
> >
> > {exec-at-unpause}
> > ```slip-script
> > slip.setClass(document.querySelector("#jon"), "dismissed", true)
> > ```
> >
>
> {step style="display: none"}
> > {exec-at-unpause}
> >  ```slip-script
> >  slip.setClass(document.querySelector("#lyrm"), "active", true)
> >  ```
> >
> >  {exec-at-unpause}
> >  ```slip-script
> >  slip.setClass(document.querySelector("#lyrm"), "dismissed", true)
> > ```
> >
> > {exec-at-unpause}
> > ```slip-script
> > argos = document.querySelector("#argos")
> > container = document.querySelector("#container")
> >
> > slip.setStyle(argos, "width", "33%")
> > slip.setClass(container, "two_elems", false)
> > slip.setClass(container, "three_elems", true)
> > ```
> >
> > {exec-at-unpause}
> >  ```slip-script
> >  slip.setClass(document.querySelector("#sabine"), "active", true)
> >  ```
> >
> >  {exec-at-unpause}
> >  ```slip-script
> >  slip.setClass(document.querySelector("#sabine"), "dismissed", true)
> > ```
> >
> > {exec-at-unpause}
> > ```slip-script
> > argos = document.querySelector("#argos")
> > container = document.querySelector("#container")
> >
> > slip.setStyle(argos, "width", "0%")
> > slip.setClass(container, "two_elems", true)
> > slip.setClass(container, "three_elems", false)
> > ```
> >
>
> {slip}
> > # ![](ocaml_logo.png){height=130px style="padding-right: 8px;vertical-align: -20px;"}.org and [odoc 3]{style="font-size:2em"}
> >
> > ![](odocCI.svg){width="100%" style="margin-bottom: -100px"}
> > 
> > - Write a new CI that uses `odoc_driver` to build the documentation
> >
> > {.unrevealed #jontookcare .block}
> > > That looked a bit complicated [$\rightarrow$]{style="padding-left:15px;padding-right:15px;"}
> > > **Jon took care of it.**
> >
> > - Use the output of the new CI in ocaml.org to get documentation
> >
> > {.unrevealed #handlingredir .block}
> > > - Handling redirection,
> > > - New CSS,
> > > - Replace Ocaml.org's sidebar and breadcrumbs,
> > > -  ...
> > >
> > > Converting to HTML is not as easy as it seems!
> >
> >
> > {#box1}
> > >
> >
> > {#box2}
> > >
> >
> > {step focus-at-unpause=box1}
> >
> > {step unfocus-at-unpause}
> >
> > {step reveal-at-unpause=jontookcare}
> >
> > {step focus-at-unpause=box2}
> >
> > {step unfocus-at-unpause}
> >
> > {step reveal-at-unpause=handlingredir down-at-unpause=handlingredir}
> >
>
> {slip no-enter #argos style="width:0%"}
> > # [Argos]{style="font-size: 2em"}
> >
> > - A tool to catch bitcoin's bad guys
> >
> > - Better than the concurrents!
> >
> >
>
> {slip no-enter #outreachy style="width:0%"}
> > # Outreachy mentoring
> >
> > - Super nice experience
> >
> > - Sometimes very strong candidates
> >
> > - What you do is helpful
>

{step}

{#duneprs pause}
> [ocaml/dune#11800](https://github.com/ocaml/dune/pull/11800) and [ocaml/dune#11716](https://github.com/ocaml/dune/pull/11716)

{#ocamlprs}
> [ocaml/ocaml.org#3124](https://github.com/ocaml/ocaml.org/pull/3124)

{#ty}
> # Thank you for your attention

<style>
#duneprs {
    position: absolute;
    top: 1326px;
    padding: 30px;
    width: 400px;
    background: yellow;
    left: 181px;
}
#ocamlprs {
    position: absolute;
    top: 1326px;
    padding: 30px;
    width: 400px;
    background: yellow;
    left: 781px;
}
#ty {
    position: absolute;
    top: 1726px;
    padding: 30px;
    width: 900px;
    background: yellow;
    left: 281px;
}
</style>
