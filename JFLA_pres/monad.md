# Les monades

{.block #questcequnc}
Une monade représente un calcul. {pause} **Qu'est-ce qu'un calcul?**

{#grid-2 pause up=questcequnc}
-----

{style="grid-column: span 2; text-align: center"}
----

## Assembleur

----

![](calcul.draw){#cdr}

```
loop:
    cmp  eax, 1      ; Check if number is 1
    je   done        ; If yes, stop
    test al, 1       ; Check if odd
    jz   even        ; If 0, jump to even case
    imul eax, 3      ; n = n * 3
    inc  eax         ; n = n + 1
    jmp  loop        ; Restart loop

even:
    shr  eax, 1      ; Divide by 2
    jmp  loop        ; Restart loop

done:
```

----

- Ressemble à une liste d'instructions à éxécuter, {draw=cdr} {pause}



- Mais l'instruction suivante dépend de l'éxécution de la précédente. {draw=cdr} {draw=cdr} {pause}

- "Expressions" très limitées {draw=cdr}

{style="grid-column: span 2; text-align: center"}
----

{pause up}
## Langage impératif

----

```
while(x != 1) {
  if (x mod 2 === 0)
    x = x / 2
  else
    x = 3 * x + 1
}
```

{#sepinstr}
----

{draw=cdr}

{draw=cdr}

{draw=cdr}

Instructions{style=color:red} versus expression{style=color:green}.

- Instructions sous forme de listes, separated with `;`. L'ordre d'évaluation est important (mais facile). 

- Expressions sous forme arborescente. L'ordre d'évaluation n'est pas clair mais pas important.


{pause down draw=cdr}
----

```
function with_log(x) {
  console.log(x);
  return x;
}

x1 = with_log(false) || with_log(true);

function or (x,y) {
  return x || y;
}

x2 = or (with_log(false), with_log(true));

```

----

En réalité: ordre d'éxécution moins trivial !

- Quel sera l'output de ces programmes ?

{style="grid-column: span 2; text-align: center" up}
----
## Langage fonctionnel
----

```
let rec syracuse =
  if x = 1 then ()
  else syracuse
         (if x mod 2 then x / 2
          else 3 * x + 1)
```


----

- Uniquement des expressions!

- En cas d'effets de bords: même problème d'ordre d'éxécution!

-----

{pause}
{.block title="Valeurs pures"}
Les expressions pures sont les expressions ne contenant pas d'effet de bord. **L'ordre d'évaluation d'une expression pure ne change rien.**

{.block #idee-generale title="Idée générale" style=height:300px}

![](idee-generale.draw){#igd}

{draw=igd}

{draw=igd}

{draw=igd}

{pause #reprg up=idee-generale}
## Représentations fonctionelle d'un calcul: `'a io`

{style=display:inline-block}
```
r1:= (
    r2 := expr1;
    return expr2
  );
r3 := return expr3;
return expr4
```

![](bind.draw){#bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{up=reprg}

{draw=bindraw}

{draw=bindraw}

{draw=bindraw}

{pause style=margin-top:600px up}
## API d'une monade

{.definition}
> Une monade est un patron de conception pour définir un calcul. Une monade est:
>
> - Un type `'a t`,
>
> - Une fonction `return : 'a -> 'a t`, calcul sans effet de bord
>
> - Une fonction `bind : 'a t -> ('a -> 'b t) -> 'b t` pour chainer deux calculs.

{pause}

Il est souvent utile d'inclure:

- `run : 'a t -> 'a` pour faire tourner un calcul

- Des fonction supplémentaires dépendant de la monade.

{.example title="Exemples de monades correspondant à des variations de calculs" pause}
- Effets de bords

- Calculs asynchrones

- Exceptions
