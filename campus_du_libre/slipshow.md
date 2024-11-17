# Slipshow

<style>
.flex {
  display: flex;
    justify-content: space-evenly;
}
.grow {
  flex-grow: 1;
}
</style>

- Slipshow est un logiciel libre pour faire des présentations améliorées. {pause}

- Avec slipshow, pas besoin de gérer l'alignement du texte ! {pause}

- Une présentation slipshow prend la forme d'un fichier texte.

{pause}

{.example #example}
  ```markdown
  # Ceci est un titre

  Et ceci est un paragraphe.

  - Et ceci est une liste à points
  - Avec plusieurs points

  On peut aussi mettre du texte **en gras**, ou en *italique*.
  ```

{pause}

Mais le truc **VRAIMENT** cool, avec slipshow, c'est :

...

{.block #cool title="Le truc vraiment cool" pause}
> Supsense, suspense...
>
> ## **On peut faire dérouler un [slide]{#slide} [~~slide~~ slip]{#slip style="position:absolute; visibility:hidden; color:red;"} !** {pause up=example}

{pause unstatic-at-unpause=slide static-at-unpause=slip}

{pause #vrai-sommaire up=cool}
## Sommaire

Cette présentation se fera en **quatre parties** :

{#sommaire}
- Humiliation des concurrents ✅

- Comment **présenter** avec slipshow

- Comment **écrire** une présentation slipshow

- Comment **installer** slipshow

{pause up=sommaire style="text-align:center" #comment-presenter}

{#part1}
> ## Comment présenter avec slipshow
>
> {.flex}
> > `←` / `→`, `↑` / `↓`, `SPACE`
> >
> > Avancer/Reculer
>
> {.flex}
> > `w` / `W`, `h` / `H`, `x` / `X`
> >
> > ?
>
> {pause}
>
> - Laisser le contenu **suffisement longtemps** à l'écran. {pause up=comment-presenter}
>
> - Compléter **les trous** avec la fonction **d'annotation**.
>
> - Faire apparaître la structure de la présentation. {pause up=vrai-sommaire} {pause unstatic-at-unpause=part1} {pause static-at-unpause=part1 up=comment-presenter}
>
> - **En embrassant les nouvelles possibilités [pédagogique]{step focus-at-unpause}** 
>
> {pause unfocus-at-unpause}
>
> Voici [quelques](https://choum.net/panglesd/slides/cea.html#0,2) exemples.

{pause up=vrai-sommaire}

{pause unstatic-at-unpause=part1 #part2}
## Comment écrire une présentation slipshow

{pause}

1. On écrit dans un **fichier texte** {pause} du **markdown** {pause} avec des **annotations**. {pause}

2. Il n'y a pas de 2.

{.block up=part2 pause title="Example"}
> {.flex}
> > ```markdown
> > ### Ceci est un titre
> >
> > Et _ceci_ est un **paragraphe**.
> >
> > {pause}
> >
> > - Une liste à `points` {pause}
> > - Avec plusieurs points
> > ```
> > {pause}
> > > ### Ceci est un titre
> > >
> > > Et _ceci_ est un **paragraphe**.
> > >
> > > {pause}
> > >
> > > - Une liste à `points` {pause}
> > > - Avec plusieurs points

{.block pause down title="Example"}
> {.flex style="gap: 20px"}
> > {style="width:60%"}
> > ```markdown
> > {.definition title="La définition"}
> > $D$ tel que $D=\{x : x\in x\}$.
> >
> > {pause}
> >
> > Marche aussi avec `theorem`,
> > `example`, `block`, `proof`, ...
> > ```
> >
> > {pause}
> > > {.definition title="La définition"}
> > > $D$ tel que $D=\{x : x\in x\}$.
> > >
> > > {pause}
> > >
> > > Marche aussi avec `theorem`, `example`, `definition`, `proof`, ...

