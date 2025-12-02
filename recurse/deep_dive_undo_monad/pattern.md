# Monads: a design pattern

{style="display:flex;gap:20px;justify-content:space-around"}
> ### Statements
>
> ```javascript
> let x = <expr>
>
> if(<expr>) {
>   <statement>
> } else {
>   <statement>
> }
>
> <statement> ; <statement>
> ```
>
> {#batman}
> ```
> do_the_laundry();
> go_to_the_cinema("Batman");
> finish_your_presentation()
> ```
> ---
>
> ### Expressions
>
> ```javascript
> 5
>
> "hello"
>
> f(<expr>,<expr>)
>
> <expr> ? <expr> : <expr>
> ```

![](ooe.draw){draw}

{up=batman}

```javascript
function with_effect(x) {
  console.log(x);
  return x
}

with_effect(false) || with_effect(true)

```

{pause}
```javascript

function or (a, b) {
  return a || b
}

or(with_effect(false), with_effect(true))
```
