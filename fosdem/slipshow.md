<style>
 .slip {
   line-height : 47px;
 }
 .show .mydiff {
   background-color: lightgreen;
 }
 .author {
  font-size: 35px;
 }
 .fosdem {
  font-size: 30px;
 }
 .fff {
  font-size: 20px;
 }
 .bof {
  font-size: 10px;
 }
 .date {
   font-weight: bold;
   color: orangered;
 }
</style>

# Slipshow [by Paul-Elliot]{.author} [at FOSDEM]{.fosdem} [Friendly Functional Languages Show And Tell]{.fff} [BOF]{.bof}

{pause}

[September 2019]{.date}: The first ever [Slipshow](https://choum.net/panglesd/slides/slides-js/slides.html) presentation. Engine written in Javascript in 3 month.

{pause}
[September 2023]{.date}: {pause} nothing.

{pause}
[November 2023]{.date}:
- You **compile** from extended **markdown to presentations**.
- Presentations are **self-contained file**.
- You write your presentation with **live preview**.
- Sliphub is a **collaborative editing server** for slipshow.
- A **Tauri app**
- and a **VSCode plugin** allows non-CLI users to run Slipshow locally. {pause}

**All written in OCaml...** (Except the engine)

{#dec pause .block}
**December 2023**: No more bugs in Slipshow. {pause} [**(Except the engine.)**]{style="font-size:1.2em"}

For instance, **going back is broken** [🤷]{style="font-size:2.2em"}.

{up=dec pause .block}
**December 2024**: Engine rewritten in OCaml and going back fixed.

{#i .block title="From step n to step n-1"}
> **Javascript engine**:
> - Refresh to step $0$
> - Go from step $0$ to $1$ to ... to $n-1$
>
> {pause}
>
> **OCaml engine**:
> - Every forward step returns a backward step function.

{.remark pause center}
[How to write the forward and backward functions in a reasonable way?]{style="font-size: 1.2em"}

{pause .theorem}
[Use a monad!!!?]{style="font-size: 1.2em"}

{pause down="code"}

<pre id="code"><code class="hljs nohighlight"><span class="hljs-keyword">let</span> update_pause_ancestors <span class="hljs-literal">()</span> =
  <span class="hljs-keyword">let</span><span class="mydiff">*</span> <span class="hljs-literal">()</span> =
  <span class="hljs-comment">(* 1. Remove all the `pauseAncestors` classes *)</span>
    <span class="hljs-type">Brr</span>.<span class="hljs-type">El</span>.fold_find_by_selector
      (<span class="hljs-keyword">fun</span> elem <span class="mydiff">undo</span> -&gt;
        <span class="mydiff"><span class="hljs-keyword">let</span>* <span class="hljs-literal">()</span> = undo <span class="hljs-keyword">in</span></span>
        set_class<span class="mydiff">_u</span> <span class="hljs-string">"pauseAncestor"</span> <span class="hljs-literal">false</span> elem)
      (<span class="hljs-type">Jstr</span>.v <span class="hljs-string">".pauseAncestor"</span>) (<span class="mydiff">return</span> <span class="hljs-literal">()</span>)
  <span class="hljs-keyword">in</span>
  <span class="hljs-comment">(* 2. Find the new first pause, *)</span>
  <span class="hljs-keyword">match</span> find_next_pause <span class="hljs-literal">()</span> <span class="hljs-keyword">with</span>
  | <span class="hljs-type">None</span> -&gt; <span class="mydiff">return</span> <span class="hljs-literal">()</span>
  | <span class="hljs-type">Some</span> elem -&gt;
      <span class="hljs-comment">(* 3. Add the "pauseAncestor" class to all its parent *)</span>
      <span class="hljs-keyword">let</span> <span class="hljs-keyword">rec</span> hide_parent elem =
        <span class="hljs-keyword">let</span><span class="mydiff">*</span> <span class="hljs-literal">()</span> = set_class<span class="mydiff">_u</span> <span class="hljs-string">"pauseAncestor"</span> <span class="hljs-literal">true</span> elem <span class="hljs-keyword">in</span>
        <span class="hljs-keyword">match</span> <span class="hljs-type">Brr</span>.<span class="hljs-type">El</span>.parent elem <span class="hljs-keyword">with</span>
        | <span class="hljs-type">None</span> -&gt; <span class="mydiff">return</span> <span class="hljs-literal">()</span>
        | <span class="hljs-type">Some</span> elem -&gt; hide_parent elem
        <span class="hljs-keyword">in</span>
      hide_parent elem
</code></pre>


{pause exec-at-unpause}
```slip-script
document.body.classList.add("show");
let undo = {undo : () => {document.body.classList.remove("show")}};
return undo;
```

{pause center}
# Thanks!

https://github.com/panglesd/slipshow/
