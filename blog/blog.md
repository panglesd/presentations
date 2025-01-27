# "Rewrite it in OCaml"

A bit more than three years ago, my past self was attending his first job interview as a software developer. He had to choose and send a snippet of code he had written, as a basis for discussion.

But first, let me introduce my past self. He was very... young, enthusiastic, and blissfully inexperienced. His programming style was fast and furious. He was also so innocent: he had no users on any of his projects.

The company he was applying to was Tarides, which specializes in the OCaml programming language. My past self, however, sent... the messiest JavaScript function from a project we (past-self and I) were excited about, Slipshow. It was a perfect representation of him: an unmaintainable solution hastily hacked together to solve a difficult problem, and it worked... brittly well.

My past self’s enthusiasm must have hacked the interviewer’s brain because I got the job. Or maybe it’s better to be genuinely excited about your work than to show off clean code. Either way, the interviewer probably wanted to steer the conversation to safer grounds, so they asked the only good question you can ask about such JavaScript code:

> How would you rewrite that in OCaml?

I completely forgot what I answered back then. However, after three years of OCaml training, two Mirage retreats, two months of unpaid leave dedicated to this question, and an NLNet grant, I can now give a proper answer. This is the story of a very elegant rewriting in OCaml.

(I really wish I could have answered with what follows in real time during the interview!)

---

## The JavaScript Code

Here’s the infamous "messiest JavaScript function":

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

I’ve left it in its natural state, with the scars printf debugging and tatooed comments. Don’t miss the highlight: a call to `this.doRefresh`, an effectful function, inlined as an argument to `console.log`! That is sooo past-self! (Side note: past-self was also teaching JavaScript… poor students.)

Let’s not dive into this code too deeply—it’s just here to set the scene. I’ll explain what it’s about. Slipshow, the project this snippet is from, is presentation software similar to PowerPoint or LaTeX + Beamer, but it’s not based on slides. Part of it is essentially a glorified script scheduler. For instance, imagine you’re giving a presentation on "Infinite Computations in Algorithmic Randomness and Reverse Mathematics." (If that doesn’t speak to you, pick another topic, but this example has the advantage of being historically accurate!)

At the beginning of your presentation, you decide to use the title’s terms to create the table of contents:

**TODO: Add GIF here.**

The scripts your glorified scheduler executes when you press the right arrow key are:

1. Scroll the window down to make space.
2. Show `I.` and move "Infinite computations" there.
3. Show `II.` and move "Algorithmic randomness" there.
4. Show `III.` and move "Reverse Mathematics."

Here’s the code responsible for the animation above, frenziedly written by my irresponsible past self. (Only the comments were added by my present self.)

```javascript
title.setAction([
  // 1. Scroll the window down to make space
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

---

## The Problem with "Previous"

The scheduler is simple: it keeps track of the last executed script, and every time the presenter presses the right arrow key, it executes the next script.

But what happens when you are crazy enough press the left arrow key? Do you just run the previous script? No, not at all! To go back, you need to *undo* the previous script’s side effects.

For instance, if you press right, then left, the following actions need to be executed:

1. Scroll the window down to make space.
2. Scroll the window **up** by the same amount.

**TODO: Add GIF here.**

But what is the inverse of the second action:

> Show `I.` and move "Infinite computations" there.

This script erases information. Undoing it requires knowing the state before it ran: putting back "Infinite computations" where it was depends on... well, where it was.

My past self spent five minutes thinking about this before coding the first solution that came to mind:

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

To go from step n to step n-1, all you have to do is know how to go to step 0: Then, you can go to step n-1 by executing the scripts. This is what the snippet above does: Refresh by setting the innerHTML back to its original, and then calling `next` n-1 times.

Does it work? Sure. Is it good? Not at all! This approach makes Slipshow’s engine unmaintainable, as one basic feature —going back— adds complexity everywhere else.

But past-self "fixed" all the problem by introducing more complexity:
- Windows movement should make it look like we go from n to n-1, not from n to 0 to n-1, so we introduce special behavior.
- It's too long to start from scratch, so there are multiple snapshot points.
- It's better to store a cloned DOM than the "inner HTML".
- Some parts should not be refreshed, eg the canvas on which you can draw, so we extract them from the cloning.
- Multiple slips can be included in each other but keep their state, so we refresh them _independently_.

No matter past self efforts, there are still problems with animations.

**TODO: Add GIF here.**

---

### The OCaml solution

I haven't introduced my present self. He is an old grumpy guy! He takes so long thinking about how to do things, that he barely does anything. He is a bit of a coward: he never dares to introduce a breaking change. His coding is perfect, but takes ages to complete! He loves the purity of functional programming, at a point where his hello-world programs do not have side effects, such as printing a string. He is experienced, he is even *senior*, he goes to a lot of boring meetings, spreading his wisdom. He *plans* the basic functionality he is going to code during 3 months, then do it in one hour.

He was ready. Ready to answer the interviewer's question. Overtrained for that.

> How would you rewrite that in OCaml?

Easy: I would define a monad. ("Exact!" would have answered the interviewer, for sure (he is also an OCaml programmer, after all)).

#### The plan

The idea is simple but powerful: Each script execution would not only have the desired effects but would also return an inverted script to undo them. This approach ensures reversibility without the brittle complexity of refreshing the entire state.

For instance, let’s revisit (part of) step 2 of the JavaScript code with this idea in mind:

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

In this example, we store the original state (`old_top`) before applying the new one, then return a function to undo the change.

While this approach seems to work in this small example, it *looks* it won't scale: A single line (setting a style attribute) is turned into five. When defining multiple complex scripts, it will be lot of work and difficulty to revert them by hand.

#### The OCaml implementation

But it only *looks* this way because we are not using OCaml, and its great support for monadic code. In this section, we will:
- Define the type and basic values,
- Define how to combine basic values,
- Introduce the syntax required to achieve transcendance.

Let's start with the type definition, and an example of an undoable computation we have already seen: setting a style to a new value.

```ocaml
(** An undoable value is a value, and a function to revert the side-effects of its computation *)
type 'a undoable = 'a * (unit -> unit)

(** Helper to create an undoable value, with a default undo *)
let return ?(undo = fun () -> ()) v = (v, undo)

(** A function to set a style in an undoable way *)
let set_style_u elem style new_value =
  let old_value = get_style elem style in
  let () = set_style elem style new_value in
  let undo () = set_style elem style old_value in
  return ~undo ()
```

We now need to combine undoable computations, which is the first miracle. This combination is going to be called `bind` for historical reasons. It takes an undoable value, a function continuing the computation, and combines them into an undoable value.

```ocaml
(** "x" is an undoable value, and "f" is a computation producing undoable values,
    "bind f x" is the undoable value "f x" undoing both side effects *)
let bind f x =
  let x, undo1 = x in
  let y, undo2 = f x in
  let undo () =
    let () = undo2 () in
    undo1 ()
  in
  (y, undo)
```

(Notice that you need to revert *first* the *last* executed script: `undo2` before `undo1`. An insane discovery.)

Present self decided to sit for one year, think very hard, write design sheets, investigate existing solutions, apply for a grant, profile prototypes, go to conferences, in order to finally write those eight lines of code! Really worth it!

Now that we have undoable script for some very basic building blocks (such as changing the style), and that we can *combine* them (using `bind`), we are going to be able to write complex scripts and get the undo function for free!

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

For instance, let's take a subset of the second step (TODO: add links), in OCaml. Without the need to revert the side effects, it would be written like this:

```ocaml
let step () =
  let () = set_style calcul Top (top + 60) in
  let () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

Using `bind` and `set_style_u`, we could rewrite it like that:

```ocaml
let step () =
  bind (set_style_u calcul Top (top + 60)) (fun () ->
    bind (set_style_u i Top (top + 60)) (fun () ->
      set_style_u i Visibility "visible"
    )
  )
```

Ouch! Much less readable... We'll solve that later. First, let's verify that it is what we want it to be: a function setting the three values, and returning a function to revert them to their original values.

When we expand the `bind`s according to its definition, we get:

```ocaml
let step () =
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
  let (), undo1 = set_style calcul Top (top + 60) in
  let (), undo2 = set_style i Top (top + 60) in
  let (), undo3 = set_style i Visibility "visible" in
  (), (fun () -> undo3 (); undo2 (); undo1 ())
```

Exactly what we wanted it to be! Combining atomic undos with `bind` seem to work. However, there is a big problem: Using `bind` makes the code much less readable.

Fortunately, OCaml has a special syntax, which is _very_ well suited for monads: custom let-bindings. If you define a function whose name is `let` followed by special characters, it can be applied in a specific way:

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
  let> () = set_style calcul Top (top + 60) in
  let> () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

At this point, your mind should be blown! At least mine is. This code looks _exactly_ like the normal code you would write (TODO LinK) but is actually building a function to undo the side effects. Well done, OCaml!

Let's conclude this part with a comparison of the approach from past-self and present self:

### You want more? A more complex real life example

This may look too simple to really show the advantages of OCaml's powerful syntax to hide the reverted script. Indeed, it would have been possible and more explicit to manually handle and combine the undos.

So, let me describe a more situation, to show that scripts in Slipshow are complex, and that programming them with the "undoable" monad is very, very efficient.

Slipshow has the concept of pauses. When you have a pause element, everything after it is hidden. When you press next, the first pause is "consumed", revealing everything that's after it, until the next pause.

TODO: gif.

Implementing the "everything after it is hidden" is actually not trivial: in particular, there is no CSS rule to select all that is displayed after an element. So, past-self had to come up with a solution (that present self found very good, he would not have done better!).

Past-self solution to hide everything that comes after is a combination of CSS and Javascript. In CSS, we can easily select what is an "sibling shown after". In javascript, we can easily mark all parents. But in fact everything that comes after, has a parent which is a sibling that comes after a parent of the pause element! Very clear, isn't it?

TODO: drawings.

So, with this in mind, what is "consuming a pause"? You need to:
- Remove all the `pauseAncestors` classes.
- Find the first pause, remove the class.
- Find the next pause
- Add the pauseAncestor class to all of its parent.

This would, in my opinion, be unreadable without the undoable monad. Here is this version:

```ocaml
let update_pause_ancestors () =
  let> () =
  (* Remove the pauseAncestor class on the result of the .pauseAncestor query *)
    Brr.El.fold_find_by_selector
      (fun elem undoes ->
        let> () = undoes in
        set_class "pauseAncestor" false elem)
      (Jstr.v ".pauseAncestor") (Undoable.return ())
  in
  (* Find the next pause elem, if there is one *)
  match find_next_pause () with
  | None -> Undoable.return ()
  | Some elem ->
      (* Add the pauseAncestor class to all its parent *)
      let rec hide_parent elem =
        if Brr.El.class' (Jstr.v "universe") elem then Undoable.return ()
        else
          let> () = set_class "pauseAncestor" true elem in
          match Brr.El.parent elem with
          | None -> Undoable.return ()
          | Some elem -> hide_parent elem
      in
      hide_parent elem
```

Exactly like you would write it without the reverted script!!!!!

## Conclusion

Dear interviewer,

I hope you are reading this! Was it what you had in mind when you asked the question?

Anyway, I really enjoyed rewriting my project in OCaml. It was a very enjoyable process, and I would do it again, one hundred times!

I hope you liked this use of a monad!

---

And the whole 

---

Disappointed? I hope not! Let me explain, not what this code does, but _why_ this code.

So, why define this specific `bind` operation, instead of `combine` which just combines Notice that in order to undo both side effects, you need to undo _first_ the _last_ side effect.


---

Unfortunately, Javascript does not yet provide a feature to run a script backward. In fact, it is even harder than running a script backward. For instance, suppose you have the following script:

```javascript
() => {
  x = 5;
}
```

Running this script in reverse 

> 

After asking the audience, you display the solution:

> It left its Windows open.


## Autre essai

Recently, I did the most reasonable thing to do: I **rewrote my main project in OCaml**.

The experience was so **satisfying** that I though I could share the **most interesting parts**.

And, since I am a monomaniac, I decided to write this "blog post" using the rewritten tool itself: Slipshow!

So what is this project, and what did I gained rewriting it in OCaml? Let's start with the killer issue I had.

Slipshow is a presentation tool. Each time the presenter hits a specific button (such as [→]{style="display:inline-block; background-color: lightgray; border: 1px solid black; border-radius: 10px"}), the presentation advances by one step.

However, a step can be _any_ user-defined function, and at the beginning it could _only_ be a user-defined function.

{pause center=f1}
Let's look at the source of the first ever slipshow presentation:

{#f1 style="height:600px; overflow:scroll"}
```javascript
title.setAction([
    (slide, engine, presentation) => {
	engine.moveWindowRelative(0,1/3,0,0,1);
    },
    (slide, engine, presentation) => {
	let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
	slide.query(".calcul").style.top = (top+60)+"px";
	slide.query(".calcul").style.left = slide.query(".aleat").offsetLeft+"px";
	slide.query(".I").style.top= (top+60)+"px";
	slide.query(".I").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
	slide.query(".I").style.visibility = "visible";
    },
    (slide, engine, presentation) => {
	let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
	slide.query(".aleat").style.top = (top+60+150)+"px";
	slide.query(".aleat").style.left = slide.query(".aleat").offsetLeft+"px";
	slide.query(".II").style.top= (top+60+150)+"px";
	slide.query(".II").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
	slide.query(".II").style.visibility = "visible";
    },
    (slide, engine, presentation) => {
	let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
	slide.query(".reverse").style.top = (top+60+300)+"px";
	slide.query(".reverse").style.left = slide.query(".aleat").offsetLeft+"px";
	slide.query(".III").style.top= (top+60+300)+"px";
	slide.query(".III").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
	slide.query(".III").style.visibility = "visible";
    }
});
```

As we can see, the presentation is just a list of scripts. The Slipshow engine is responsible for running the script at the right moment. This makes it easy to create highly animated live presentations.

However, there is a BIG issue. How to go back to a previous state? Indeed, we have the forward function, but not the reverted one!

The way it worked (before the OCaml rewrite) was the following:

- The 
