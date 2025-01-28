# How I fixed Slipshow's worst flaw using OCaml and a monad

A bit more than three years ago, my past self was attending his first job interview as a software developer. He had to choose and send a snippet of code he had written, as a basis for discussion.

But first, let me introduce my past self. He was very... young, enthusiastic, and blissfully inexperienced. His programming style was fast and furious. He was also so innocent: he had no users on any of his projects.

The company I was applying to was Tarides, which specializes in the OCaml programming language. My past self, however, sent... the messiest JavaScript function from a project we (past-self and I) were excited about: [Slipshow](https://github.com/panglesd/slipshow/). It was a perfect example of his coding style: an unmaintainable solution hastily hacked together to solve a difficult problem, and it worked... brittly well.

My past self’s enthusiasm must have hacked the interviewer’s brain because I got the job. Or maybe it’s better to be genuinely excited about your work than to show off clean code. Either way, the interviewer probably wanted to steer the conversation to safer grounds, so they asked the only good question you can ask about such JavaScript code:

> How would you rewrite that in OCaml?

I completely forgot what I answered back then. However, after three years of OCaml practice, two [Mirage retreats](https://retreat.mirage.io/), two months of unpaid leave dedicated to this question, and an [NLNet grant](https://nlnet.nl/project/Slipshow/), I can now give a proper answer.

This is the story of a rewrite gone _right_ -- one that unearthed a surprisingly elegant OCaml gem hidden in Slipshow’s chaotic JavaScript wilderness!

(I really wish I could have answered with what follows in real time during the interview! :nerd_face:)

## The JavaScript Code

I'll show you the code that was thrown at the interviewer really soon, but first let me give a bit of context.

[Slipshow](https://github.com/panglesd/slipshow/), the project this snippet is from, is a presentation software similar to PowerPoint or LaTeX + Beamer, but based on scripted scrolling, rather than slides.

The infamous "messiest JavaScript function" implemented how to go back in a presentation. Here it is, do not stare at it too long (it's dangerous):

```javascript
this.previous = () => {
  let savedActionIndex = this.getActionIndex();
  let savedDelay = this.currentDelay;
  this.getEngine().setDoNotMove(true);
  console.log("gotoslip: we call doRefresh",this.doRefresh());
  if(savedActionIndex == -1)
      return false;
  let toReturn;
  while(this.getActionIndex()<savedActionIndex-1){
      console.log("previous is ca we do next", this.getEngine().getDoNotMove());
      console.log("(figure) actionIndex is", actionIndex);
      toReturn = this.next();
  }
  // if(!this.nextStageNeedGoto())
  //     this.getEngine().setDoNotMove(false);
  // while(this.getActionIndex()<savedActionIndex-1)
  //     toReturn = this.next();
  setTimeout(() => {this.getEngine().setDoNotMove(false);},0);
  this.getEngine().gotoSlip(this, {delay:savedDelay});
  return toReturn;

  // return this.next;
};
```

I’ve left it in its original state, with the scars printf debugging and tattooed comments. Don’t miss the highlight: a call to `this.doRefresh`, an effectful function, inlined as an argument to `console.log`! That is sooo past-self! (Side note: past-self was also teaching JavaScript… poor students.)

Part of Slipshow is essentially a glorified script scheduler. Each step in the presentation is represented by a function, that Slipshow executes at the right moment. Nowadays, the function for each steps are derived from small annotations in the source document. However, at the beginning of Slipshow, the author had to provide them, and we'll place ourselves in this situation for our example.

Imagine one day you’re giving a presentation on "Infinite Computations in Algorithmic Randomness and Reverse Mathematics." (This odd choice of example has the advantage of being [historically accurate](https://choum.net/panglesd/slides/slides-js/slides.html): it was the first ever slipshow presentation!). At the beginning of your presentation, you decide to use the title’s terms to create the table of contents:

![](https://choum.net/panglesd/going_forward8.gif)

<!-- **TODO: Add GIF here.** -->

The steps your glorified scheduler executes when you press the right arrow key are:

1. Scroll down to make space.
2. Show `I.` and move "Infinite computations" there.
3. Show `II.` and move "Algorithmic randomness" there.
4. Show `III.` and move "Reverse Mathematics."

Here’s the code responsible for the animation above, as it was frenziedly written by my irresponsible past self. (Only the comments were added by my present self.)

```javascript
title.setAction([
  // 1. Scroll down to make space
  (slide, engine, presentation) => {
    engine.moveWindowRelative(0,1/3,0,0,1);
  },
  // 2. Show `I` and move "Infinite computations" there
  (slide, engine, presentation) => {
    let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
    slide.query(".calcul").style.top = (top+60)+"px";
    slide.query(".calcul").style.left = slide.query(".aleat").offsetLeft+"px";
    slide.query(".I").style.top= (top+60)+"px";
    slide.query(".I").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
    slide.query(".I").style.visibility = "visible";
  },
  // 3. Show `II` and move "Algorithmic randomness" there
  (slide, engine, presentation) => {
    let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
    slide.query(".aleat").style.top = (top+60+150)+"px";
    slide.query(".aleat").style.left = slide.query(".aleat").offsetLeft+"px";
    slide.query(".II").style.top= (top+60+150)+"px";
    slide.query(".II").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
    slide.query(".II").style.visibility = "visible";
  },
  // 4. Show `III` and move "Reverse Mathematics."
  (slide, engine, presentation) => {
    let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
    slide.query(".reverse").style.top = (top+60+300)+"px";
    slide.query(".reverse").style.left = slide.query(".aleat").offsetLeft+"px";
    slide.query(".III").style.top= (top+60+300)+"px";
    slide.query(".III").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
    slide.query(".III").style.visibility = "visible";
  }
]);
```

## The Problem with "Previous"

The "glorified scheduler" is simple: it keeps track of the last executed step, and every time the presenter presses the right arrow key, it executes the next step's function.

But what happens when you are crazy enough to press the left arrow key? Do you just run the previous step's function? No, not at all! To go back, you need to *undo* the previous step’s side effects.

For instance, if you press right, then left, the following actions need to be executed:

1. Scroll the window down to make space.
2. Scroll the window **up** by the same amount.

And what is the inverse of the second action:

> Show `I.` and move "Infinite computations" there.

This step's execution erases information. Undoing it requires knowing the state before it ran: putting back "Infinite computations" where it was depends on... well, where it was.

My past self spent five minutes thinking about this before coding the first solution that came to his mind:

```javascript
this.refresh = () => {
  this.setActionIndex(0);
  this.element.innerHTML = initialInnerHTML;
};
this.previous = () => {
  let saveCpt = this.getActionIndex();
  this.refresh();
  while (this.getActionIndex() < saveCpt - 1)
    this.next();
};
```

To go from step $n$ to step $n-1$, all you have to do is know how to go to step $0$: Then, you can go to step $n-1$ by executing the steps forward. This is what the snippet above does: Refresh by setting the innerHTML back to its original, and then calling `next` $n-1$ times. Here is the result of going forward and backward on our example:

![](https://choum.net/panglesd/going_backward2.gif)

Does it work? Kind of. Is it good? Not at all!

Not only the basic "going back" feature is not satisfyingly implemented, but this approach also makes Slipshow’s engine unmaintainable, as one basic feature —going back— leaks complexity on all other features (slips inside slips, annotations, ...).

Past-self has "fixed" some problems by introducing more complexity, so the situation with the engine wasn't as bad as it looks from the gif, but it had a big cost on developement...

## The OCaml solution

I haven't introduced my present self. He is an old grumpy guy, with strong opinion on programming language! He takes so long thinking about how to do things, that he barely codes anymore. He never dares to introduce a breaking change, and every changes are breaking. His coding is perfect, but takes ages to complete! He loves the purity of functional programming, his hello-world programs do not have side effects. He is experienced, he is even "*senior*", he goes to a lot of boring meetings, spreading his wisdom. He *plans* the basic functionality he is going to code during three years, only to implement it in three minutes. Well, he likes talking bad about himself in blog posts, but don’t take that too seriously—he’s always exaggerating!

He was ready. Ready to answer the interviewer's question. Overtrained for that.

> How would you rewrite that in OCaml?

« Easy: I would define a monad. »

("Exactly!" the reviewer would probably have answered: he is also an OCaml programmer, after all)

### The general plan

The idea is simple but powerful: Executing a step, in addition to its side-effects in the presentation, returns a function to undo them. This approach ensures reversibility without the brittle complexity of refreshing the entire state.

For instance, let’s revisit (part of) step 2 (TODO add link) of the JavaScript code with this idea in mind. Implementing this idea in Javascript would look like:

```javascript
  // 2. [...] move "Infinite computations" down,
  (slide, engine, presentation) => {
    let old_top = slide.query(".calcul").style.top;
    slide.query(".calcul").style.top = (top+60)+"px";
    return () => {
      slide.query(".calcul").style.top = old_top;
    }
  },
```

In this example, we store the original value (`old_top`) before setting the new one, then return a function to undo the change.

While this approach works, it *looks* like it's going to be very cumbersome in more complex steps: Setting a style attribute is already turned into five lines. Complex steps may be lot of work and difficulty to revert by hand.

### The OCaml implementation

It only *looks* cumbersome because we are using past-self's Javascript-fu instead of current self's OCaml-fu. As we will see, he is able to drastically lower the impact of having to generate an undo function for each step definition. Here is his plan:
- Define a type for undo-able effects, as well as basic undo-able values,
- Define how to combine basic undo-able values,
- Introduce the syntax required to achieve transcendance.

Let's start with the type definition, and an example of an undo-able computation we have already seen: setting a style to a new value.

```ocaml
(** An undo-able value is a value, and a function to revert the side-effects of
    its computation *)
type 'a undoable = 'a * (unit -> unit)

(** Helper to create an undo-able value, with a default undo *)
let return ?(undo = fun () -> ()) v = (v, undo)

(** A function to set a style in an undo-able way *)
let set_style_u elem style new_value =
  let old_value = get_style elem style in
  let () = set_style elem style new_value in
  let undo () = set_style elem style old_value in
  return ~undo ()
```

We now need to combine undo-able computations, which is the first miracle. This combination is going to be called `bind`. It takes an undo-able value, a function continuing the computation, and combines them into an undo-able value.

```ocaml
(** if "x" is an undo-able value,
    and "f" is a function "continuing the computation from x",
    then "bind f x" is the result of the computation, as an undo-able value undoing both side effects *)
let bind f x =
  let x, undo1 = x in
  let y, undo2 = f x in
  let undo () =
    let () = undo2 () in
    undo1 ()
  in
  (y, undo)
```

(Notice that you need to revert *first* the *last* side effect: `undo2` before `undo1`. An insane discovery.)

Present self pondered for one year, thought very hard, wrote design sheets, investigated existing solutions, applied for a grant, profiled prototypes, went to conferences, in order to finally write those eight lines of code! Really worth it!

Now that we have undo-able functions for some very basic building blocks (such as changing the style), and now that we can *combine* them (using `bind`), we are able to write complex scripts and get the undo function for free!

<!-- At this point, there are some questions you might have: -->
<!-- - Why a `bind` function, and not just a way to combine all undos? Something like: -->
<!--   ```ocaml -->
<!--   let combine undos () = List.iter (fun f -> f ()) (List.rev undos) -->
<!--   ``` -->
<!-- - How are we going to handle the syntax overhead of using all those `bind` everywhere to combine the undos? -->

<!-- To answer the first question, `bind` forces the computation to have an order. You have what was already computed (`x` and its side effect), and the rest of the computation (`f`). So you don't have to worry about the order: -->

<!-- ```ocaml -->
<!-- let step () = -->
<!--   let (), undo1 = set_style calcul Top (top + 60) in -->
<!--   let (), undo2 = set_style i Top (top + 60) in -->
<!--   let (), undo3 = set_style i Visibility "visible" in -->
<!--   (), combine_undos [ undo3 ; undo1 ; undo2 ] -->
<!-- ``` -->

<!-- Oh no! In the example above, I messed up the order of undos! -->

For instance, let's take a part of the second step: setting the `top` and `visibility` styles, (TODO: add links), in OCaml. Without the need to revert the side effects, it would be written like this:

```ocaml
let step () =
  let calcul = query ".calcul" and i = query ".I" in 
  let () = set_style calcul Top (top + 60) in
  let () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

Using `bind` and `set_style_u`, we could rewrite it like that:

```ocaml
let step () =
  let calcul = query ".calcul" and i = query ".I" in 
  bind (set_style_u calcul Top (top + 60)) (fun () ->
    bind (set_style_u i Top (top + 60)) (fun () ->
      set_style_u i Visibility "visible"
    )
  )
```

Ouch! Much less readable... We'll solve that later. First, let's verify that it is what we want it to be: a function setting the three values, and returning a function to revert them to their original values.

When we inline the two `bind` functions according to their definition, we get:

```ocaml
let step () =
  let calcul = query ".calcul" and i = query ".I" in 
  let (), undo1 = set_style calcul Top (top + 60) in
  let (), undo2 =
    let (), undo3 = set_style i Top (top + 60) in
    let (), undo4 = set_style i Visibility "visible" in
    (), (fun () -> undo4 (); undo3 ())
  in
  (), (fun () -> undo2 () ; undo1 ())
```

which, when we remove some intermediate variables, is equivalent to:

```ocaml
let step () =
  let calcul = query ".calcul" and i = query ".I" in 
  let (), undo1 = set_style calcul Top (top + 60) in
  let (), undo2 = set_style i Top (top + 60) in
  let (), undo3 = set_style i Visibility "visible" in
  (), (fun () -> undo3 (); undo2 (); undo1 ())
```

Exactly what we wanted it to be! Combining atomic undos with `bind` seems to work. However, there is a big problem: Using `bind` makes the code much less readable.

Fortunately, OCaml has a [special syntax](https://ocaml.org/manual/5.3/bindingops.html), which is _very_ well suited for monads: custom let-bindings. If you define a function whose name is `let` followed by special characters, it can be applied in a specific way:

```ocaml
(* What looks like a let-binding: *)
let> x = v in
body

(* is in fact a syntactic alias for the following function application: *)
(let>) (fun x -> body) v
```

Interesting! So if we rename our `bind` function to `let>`:

```ocaml
let (let>) f x = bind f x
```

then we can use it to rewrite TODO LINK TO USE OF BINDs:

```ocaml
let step () =
  let calcul = query ".calcul" and i = query ".I" in 
  let> () = set_style calcul Top (top + 60) in
  let> () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

At this point, your mind should be blown! At least mine is. This code looks _exactly_ like the normal code you would write (TODO LinK) but is actually building a function to undo the side effects. Well done, OCaml!

## A more complex real life example

This may look a bit too simple to really show the advantages of OCaml's powerful syntax to hide the reverted script. Indeed, it would have been possible and more explicit to manually handle and combine the undos.

So, let me describe a more situation, to show that programming complex scripts with the "undo-able" monad is very natural.

Slipshow has the concept of pauses. When you have a pause element, everything after it is hidden. When you press next, the first pause is "consumed", revealing everything that's after it, until the next pause.

For instance, here is a source file, and its rendered version:

```markdown
# Hello, this is a first step {pause}

- And a list {pause}
- of elements {pause}

{.block}
Followed by a block.
```

![](https://choum.net/panglesd/steps2.gif)

Implementing the "everything after a pause is hidden" is actually not trivial. In particular, it's more complex than just setting a class.

Past-self came up with a solution (that present self found very good!). It requires that all the parents of the current "paused" element have a specific class (`pauseAncestor`). Some static CSS does the rest of the job.

When a pause is consumed, the engine needs to:
1. Remove all the `pauseAncestors` classes,
2. Find the first pause, remove the class,
3. Find the new first pause,
4. Add the pauseAncestor class to all of its parent.

Without the requirement to provide an undo function, here is how I would write it:

```ocaml
let update_pause_ancestors () =
  let () =
  (* 1. Remove all the `pauseAncestors` classes *)
    Brr.El.fold_find_by_selector
      (fun elem () ->
        set_class "pauseAncestor" false elem)
      (Jstr.v ".pauseAncestor") ()
  in
  (* 2. Find the first pause, remove the class, *)
  let () = match find_first_pause () with
    | None -> ()
    | Some elem -> set_class "pause" false elem
  in
  (* 3. Find the new first pause, *)
  match find_first_pause () with
  | None -> ()
  | Some elem ->
      (* 4. Add the "pauseAncestor" class to all its parent *)
      let rec hide_parent elem =
        let () = set_class "pauseAncestor" true elem in
        match Brr.El.parent elem with
        | None -> ()
        | Some elem -> hide_parent elem
      in
      hide_parent elem
```

But of course, we need to have an undo function for all of this. How hard can it be?

```ocaml
let update_pause_ancestors () =
  let> () =
  (* 1. Remove all the `pauseAncestors` classes *)
    Brr.El.fold_find_by_selector
      (fun elem undo ->
        let> () = undo in
        set_class_u "pauseAncestor" false elem)
      (Jstr.v ".pauseAncestor") (Undo_able.return ())
  in
  (* 2. Find the first pause, remove the class, *)
  let> () = match find_first_pause () with
    | None -> Undo_able.return ()
    | Some elem -> set_class_u "pause" false elem
  in
  (* 3. Find the new first pause, *)
  match find_next_pause () with
  | None -> Undo_able.return ()
  | Some elem ->
      (* 4. Add the "pauseAncestor" class to all its parent *)
      let rec hide_parent elem =
        let> () = set_class_u "pauseAncestor" true elem in
        match Brr.El.parent elem with
        | None -> Undo_able.return ()
        | Some elem -> hide_parent elem
      in
      hide_parent elem
```

TODO: highlight differences after HackMD export

Can you see the difference? It consists only a handful of `>` and `return`, and magically an undo function is generated! Mind blown again :exploding_head:.


![](https://choum.net/panglesd/steps_backward.gif)

## Conclusion

Dear interviewer,

I hope you are reading this! Was it what you had in mind when you asked the question?

Thanks for starting this fun journey with your question! I hope you liked this use of a monad!

I really enjoyed rewriting my project in OCaml. It was a delightful process with almost no bad surprise, and I would do it again, one hundred times.

## Addendum

- I am only fluent in OCaml, so the JavaScript/OCaml comparison is unfair (but OCaml would win in a fair comparison).
- I am curious how one would do that in another language.
- The `'a undoable` type and `bind` value is a bit more complicated in real life than here due to asynchronicity, but the principle is exactly the same.
- Speaking of asynchronicity, switching to OCaml also had the huge advantage of being explicit what is async and what is not. In Javascript, my code was crippled with `setTimeout` of 0ms to wait for a css value to have taken effect.
- I did not use "Functional Reactive Programming" since I want the presentation author to write scripts modifying the DOM directly (as opposed to only being allowed to modify the state). Eg using third party javascript for animations.

Please use the following discuss (TODO: link) to comment!
