---
dimension: 16:9
css: style.css
---

# The Undo Monad in Slipshow

{pause}

![](toc.draw){#toc}

{draw=toc}

{draw=toc}

{draw=toc}

{#main-container}
> {include src="slipshow.md" slip pause=cmf-addons}
>
> {step}
>
> ![](thinking.draw){#tdra}
>
> {draw=tdra}
>
> {draw=tdra}
>
> {draw=tdra}
>
> {include src="monad.md" slip pause=monadef}
>
> {up=main-container}
>
> {exec}
> ```slip-script
> document.body.style.display = "none";
> ```
> {exec}
> ```slip-script
> document.body.style.display = "block";
> ```
>
> ![](looking-back.draw){#looking-back}
>
> {draw=looking-back}
>
> {draw=looking-back}
>
> {draw=looking-back}
>
> {draw=looking-back}
>
> {draw=looking-back}
>
> {include src="undo-monad.md" slip pause=next2}

{step}

![](merci.draw){draw}

<!-- TODO:
      - Ajouter problème de différence aller-retour
      - Refaire "Merci, avez-vous des questions"
      - Ajouter des blagues
      - Ajouter un exemple de AST monade simple
      - Ajouter une note sur l'execution de scripts
-->
