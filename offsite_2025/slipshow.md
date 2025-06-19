# Slipshow

<style>li { margin-top: 30px} </style>

{pause}

- 2019: [Written in 3 month](../thesis/slides.html)
  - Content ⚡ flow separated
  - ✋-written movement
  - Impossible to go back? but **rotation**!

{pause}

- 2020: [Some improvements](../slip-js/slides.html)
  - Content ⚡ flow unified
  - Absolute timing

{pause}

- 2020: [Naturalish flow](../WDCM-2021-slips/wdcm-ada.html)
  - Pause and `*-at-unpause` events

{pause}

- 2020: [Modularized](https://github.com/panglesd/slipshow/pull/1)

{pause down}
- Over time, [engine is "improved"](../tech_talk/links_logics_cs.html):
  - 🖊️ feature
  - Go back (still WIP)
  - Table of content
  - ...

{pause center-at-unpause}
- 2023: **Compiler, written in OCaml**!
  - From markdown to slipshow
  - Creates standalone html files
  - Live-reloading
  - Available as precompiled binaries, opam package, GUI editor, npm package, VSCode extension
  - Raising [awareness](https://news.ycombinator.com/item?id=40509638)?
  - Has users!

{pause #y2024}
- 2024?
  - Rewrite the engine in OCaml: [Secure by design]{.sbd pause} presentation tool?

{pause up=y2024}
- 2025

{.block style="text-align:center" #ithappened}
#### Slipshow's engine has been rewritten in OCaml!

{.corollary pause}
There is no more bugs in Slipshow.

{.corollary pause}
Slipshow relies on a monad.

{.corollary pause}
I can finally contribute to my own engine. {pause} No-one else can contribute.

{.corollary pause up=ithappened}
I earned 2000€.

{pause center #also}
Also:
- **Subslips** are back
- **Slides** were added
- Break your presentation in **multiple files**
- Improved **table of content**
- **More actions**

{pause .block up=also #y2026}
- 2026?

  {#biglist}
  - Rewrite the engine in OxCaml? {pause}
  - Add **AI** to slipshow? {pause}
  - Use Ocsigen!
  - Add speaker notes,
  - Add WYSIWYG features,
  - Record and replay annotations, {pause} {down=biglist}
  -  Rethink the documentation with help from a technical writer
  - Make it possible and easy to use regular slides in a slipshow presentation
  -  Make it possible and easy to use pdf and pdf slideshows in a
      slipshow presentation
  -  Write a contributing guide for Slipshow, for OCaml contributors, and
      html/css contributors
  -  Improve the default theme with help from a designer
  -  Basic record and replay mechanism
  -  Handle event happening during the animations
  -  Integrate records to the `--server` mode
  -  Edit recorded animations through UI
  -  Write documentation about record and replay
  -  Release and announce
  - Fix parsing hard failure (#58)
  - Fix file watching (#67)
  - Fix images with attributes (#30)
  - Implement `scroll-to` action (#61)
  -  Implement figure overlays (#57)
  -  Include source in artefact (#53, #55)
  -  Create actions to publish pres on forges (#51)
  -  Add a CSS framework (#43)
  -  Allow to include video/large files (#40)
  - Allow to split input in multiple files (#29)
  -  Show the state of the previewer (#68)
  -  Add support for speaker notes (#72)
  -  Fix image support for vscode plugin
  -  Add support for recording presentation with audio
  -  Add support for mermaid (#47)
  -  Add support for tikz (#46)
  -  Add support for manim (#69)
  -  Integrate with Big Blue Button
  -  Integrate with Galène or another video conferencing tool as Jitsi
  -  Implement a WYSIWYG editor in the previewer.
  -  Make it work in sliphub, the tauri app, and the vscode plugin.
  -  Upstream Brr changes
  -  Upstream Cmarkit changes
  -  Upstream CodeMirror bindings
  -  Release an operational transform library on opam
  -  Release Tauri OCaml bindings on opam
  -  Allow to create an account and manage all your presentations there
  -  Have fine-grained permission on your presentations
  -  Allow uploading images and other media
  -  Add synchronized presentation capability
  -  Add support for remote polling
  -  Add support for H5P or WebXDC apps, or develop a plugin system for
      audience participation
  - Add a pure markdown output (#71)
  -  Internationalize the output (#70)
  -  Internationalize the docs (#70)
  - Add mobile support (#50)
  -  Do an accessibility audit and process feedback
  -  Do a security audit for slipshow, sliphub, the vscode plugin and
      the tauri app. Process feedback.
  -  Make it easy to self host Sliphub (documentation for that, docker
      images, provide patched dependencies).
  -  Allow client-side local storage of presentation in Sliphub.
  -  Add support for client-side encrypting "à la cryptpad" in Sliphub.

  

<style>
@keyframes fontSizeChange { 0%,100% { scale:1; } 50% { scale: 0.5 } }
@keyframes colorChange { 0%,100% { color:red; } 33% { color: green } 66% {color: blue;} }
@keyframes rotateChange { 0%,100% { transform: rotate(10deg); } 50% { transform: rotate(-10deg) } }

.sbd {
  display: inline-block;
  animation: fontSizeChange 3s infinite, colorChange 2s infinite, rotateChange 4s infinite;
  font-size:64px;
}</style>


