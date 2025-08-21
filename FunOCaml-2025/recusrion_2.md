---
dimension: 16:9
---

<style>
#nuage-de-points.stop p {
  transition: opacity 1s;
  opacity: 0.1;
}
#nuage-de-points p {
}
#nuage-de-points.stop #video {
  opacity: 1;
}
#nuage-de-points {
  display: flex;
  flex-wrap: wrap;
  gap: 0px;
  column-gap: 157px;
  font-size: 1.2em;
  justify-content: space-around;
}
#nuage-de-points p {
  margin-top: 20px;
  margin-bottom: 20px;
}
.abs {
  position: absolute;
}
#n1 {
  top: 90px;
  left: 30px;
}
#n2 {
  top: 590px;
  left: 530px;
  transform: rotate(40deg);
}
#n3 {
  top: 350px;
  left: 930px;
}
#n4 {
  top: 280px;
  left: 990px;
  transform: rotate(-10deg);
}
#n5 {
  top: 230px;
  left: 390px;
  transform: rotate(-180deg);
}
#n6 {
  top: 430px;
  left: -150px;
  transform: rotate(90deg);
}
#n7 {
  top: 530px;
  left: 870px;
  transform: rotate(-30deg);
}
#n8 {
  top: 30px;
  left: 1670px;
  transform: rotate(-10deg);
}
#n9 {
  top: 650px;
  left: 1170px;
  transform:  translateX(350px) rotate(-90deg);
}
#n10 {
  top: 880px;
  left: 570px;
  transform:  translateX(350px) rotate(-55deg);
}
#n11 {
  top: 90px;
  left: 570px;
}
#frame.stop {
  opacity: 1;
}
#frame {
  transition: opacity 3s;
  transition-delay: 2s;
  opacity: 0;
  position: absolute;
  top: 370px;
  left: 50px;
  width: 600px;
  height: 400px;
//  background-color: rgba(255,0,0,0.5);
  overflow: visible;
}
#rec1 {
  transform:  translate(-350px, -150px) scale(0.4);
}
</style>

# Slipshow: A *full-featured* presentation tool

{#nuage-de-points children:pause}
---

{.red}
Compile markdown files

{.red}
Generate *Standalone* HTML files

{.red}
Not based on slides

Can Zoom

You can annotate your presentation

Custom scripts

{.red}
Write your presentation with hot-reloading

{.red}
Support for embedding PDFs

{#video}
Embed Videos and Audio

Available as a static binary

Available as a VSCode extension

Available with a GUI

{.red}
Bi-directional

Features a table of content

Has supports for themes

Allow the execution of custom scripts

Not based on slides (but supports them)

Extensible via JavaScript

Markdown output

{.red}
Speaker view

Frontmatter support

Mobile support

Multi-file input

{.red}
Hierarchical presentation

Many predefined actions

Extensive documentation and tutorial

Friendly community (me)

Extensive help page

Open source

Secure-by-design

Lightning fast

Has a nice logo

Fun name

Versionning-friendly

{.abs #n1}
No LLM knows about it

{.abs #n2}
Compatible with pointer devices

{.abs #n3}
Can make coffee

{.abs #n4}
Sponsored by NLNet

{.abs #n5}
Type safe

{.abs #n6}
Live-collaboration editing

{.abs #n7}
Syntax highlighting

{.abs #n8}
Offline first

{.abs #n9}
Support for environment such as `theorem`

{.abs #n10}
Adaptative scaling

{.abs #n11}
User-defined dimensions

---

{focus=frame exec}
```slip-script
let x = document.querySelector("#nuage-de-points");
slip.setClass(x,"stop", true);
let y = document.querySelector("#frame");
slip.setClass(y,"stop", true);
```

{#frame}
![](rec1.mp4){#rec1}

{play-media=rec1}
