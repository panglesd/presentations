# "Rewrite it in OCaml"

A bit more than three years ago, my past self was having my first job interview as a software developer. He had to choose and send a snippet of code he authored, as a basis for discussion.

But first, let me introduce you my past self. He was very... young and enthusiastically inexperimented. His programming was fast and furious. He was also so innocent: he had no users on any of his project.

The company for which he was applying is Tarides, whose focus is on the OCaml programming language, and so past-self sent... the messiest Javascript function for a project we (past-self and I) are excited about, Slipshow. It represented him quite well: it was an unmaintainable solution that he had quickly hacked to face a difficult problem, and it worked brittly well.

My past-self enthusiasm must have hacked the interviewer's brain, since he did get the job. Or, it is better to be excited about a project you did than to show clean code. Anyway, probably as a desperate attempt to return to safer grounds, the interviewer asked the only good question you can ask on such Javascript code:

> How would you rewrite that in OCaml?

I completely forgot what I answered. However, after three years of OCaml training, 2 Mirage retreat, 2 months of unpaid leaves focusing on that, and an NLNet grant, I can now answer you, interviewer. This is the story of a very elegant rewriting in OCaml.

(I really wish I could have answered what follows in real time during the interview!)

## The Javascript code

Let me show you the above mentioned "messiest Javascript function":

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

I left it in its natural form, with all the scars of bad printf debugging and tatooed useless comments. Do not miss the pearl: a call to `this.doRefresh`, an effectful function, inlined as an argument to `console.log`! Yay! That is soooo past-self! (You have to know that past-self was also teaching Javascript... poor students)

Apart for the sake of making fun of my past enthusiastic self, let's not read that. I'll explain what it is about. Slipshow, the project it's taken from, is a software for making presentations, as is PowerPoint or Latex+Beamer (but Slipshow is not based on slides).
It can be seen as a glorified script scheduler: For instance, suppose it's a normal day, and you are making a presentation on... Infinite Computations in Algorithmic randomness and Reverse Mathematics. (If that does not speak to you, the recipe for an apple pie would work, but I like this historical example: past-self really did that)

You have an idea: you are going to use the title's terms to create the table of content:

TODO: gif.

So, the scripts your glorified scheduler execute when you press the right arrow key are the following:

1. Scroll the window down to make space
2. Show `I.` and move "Infinite computations" there,
3. Show `II.` and move "Algorithmic randomness" there,
4. Show `III.` and move "Reverse Mathematics".

Here is the exact code responsible for the animation above, frenzily written by my irresponsible past self. Only the comments were added by my present self:

```javascript
title.setAction([
  // 1. Scroll the window down to make space
  (slide, engine, presentation) => {
    engine.moveWindowRelative(0,1/3,0,0,1);
  },
  // 2. Show `I` and move "Infinite computations" there,
  (slide, engine, presentation) => {
    let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
    slide.query(".calcul").style.top = (top+60)+"px";
    slide.query(".calcul").style.left = slide.query(".aleat").offsetLeft+"px";
    slide.query(".I").style.top= (top+60)+"px";
    slide.query(".I").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
    slide.query(".I").style.visibility = "visible";
  },
  // 3. Show `II` and move "Algorithmic randomness" there,
  (slide, engine, presentation) => {
    let top = slide.query(".main").offsetTop+slide.query(".main").offsetHeight;
    slide.query(".aleat").style.top = (top+60+150)+"px";
    slide.query(".aleat").style.left = slide.query(".aleat").offsetLeft+"px";
    slide.query(".II").style.top= (top+60+150)+"px";
    slide.query(".II").style.left= (slide.query(".aleat").offsetLeft-100)+"px";
    slide.query(".II").style.visibility = "visible";
  },
  // 4. Show `III` and move "Reverse Mathematics".
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

The glorified scheduler seems very simple: It records the last executed script, and whenever the presenter hits the right arrow key, the next script is executed.

But then, what happens when you are crazy enough to hit the left arrow key? Easy, you just run the previous script, instead of the next one. WRONG, young little past self! Executing the previous script does not work, you need to execute it's inverse. For instance, if you hit right, then left, the following actions need to be executed:

0. `right` is pushed.
0-1. Scroll the window down to make space.
1. `left` is pushed.
1-0. Scroll the window **up** the same amount.

TODO: gif

Good.

However, what is the inverse of the second script?

2. Show `I.` and move "Infinite computations" there.

Indeed, this script is "erasing" some information. When scrolling for a predefined amount of pixels, the inverted script does not depend on the execution of the script. But in this case, putting back "Infinite computations" where it was depends on... well, where it was.

Past self though for at least 5 minutes about how to solve that, before starting coding. After all, he had in mind a solution to this: To go from step n to step n-1, all you have to do is know how to go to step 0: Then, you can go to step n-1 by executing the scripts.

```javascript
this.refresh = () => {
  this.setActionIndex(0);
  this.element.innerHTML = initialInnerHTML;
};
this.previous = () => {
  let saveCpt = this.getActionIndex();;
  this.refresh();
  while(this.getActionIndex()<saveCpt-1)
    this.next();
}
```

Works well enough!?

TODO: gif

This is a very bad solution. But past-self does not see that: he "fixes" all the problem by introducing more complexity:
- Windows movement should make it look like we go from n to n-1, not from 0 to n.
- It's too long to start from scratch, there are multiple snapshot points.
- It's better to store a cloned DOM than the "inner HTML".
- Some parts should not be refreshed, eg the canvas on which you can draw.
- Multiple slips can be included in each other, and refreshed _independently_.

This is what has made Slipshow's engine turn into an unmaintainable software: One of the most basic feature (going back in the presentation) is made on a horrible basis, that complexifies all other features. Are you happy, past-self?

### The solution

I haven't introduced my present self. He is an old grumpy guy! He takes so long thinking about how to do things, that he barely does anything. He is a bit of a coward: he never dares to introduce a breaking change. His coding is perfect, but takes ages to complete! He loves the purity of functional programming, at a point where his hello-world programs do not have side effects, such as printing a string. He is experienced, he is *senior*, he goes to a lot of boring meetings, spreading his wisdom. He *plans* the basic functionality he is going to code during 3 months, then do it in one hour.

He was ready. Ready to answer the interviewer's question. Overtrained.

> How would you rewrite that in OCaml?

I would define a monad for undoable side effects. That's all. ("That's the right answer! You are hired")

Let's break down this a bit. The idea is that the script execution would also return their inverted script.

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

That *looks* quite horrible: A single line (setting a style attribute) is turned into 5 (storing the old value, setting the style, returning the reverted function).
It also *looks* it's not going to scale: When defining multiple complex scripts, it will be too much work and difficulty to revert them by hand.

But it only *looks* this way because we are not using OCaml, and its great support for monadic code. My present self tells you, listen to his wisdom!

```ocaml
(** An undoable value is just a value and a function to revert the side-effects triggered when computing it *)
type 'a undoable = 'a * (unit -> unit)

(** Creating an undoable value, with a default value *)
let return ?(undo = fun () -> ()) v = (v, undo)

(** A function to set a style in an undoable way *)
let set_style elem style new_value =
  let old_value = Style.get elem style in
  let () = Style.set elem style new_value in
  let undo () = Style.set elem style old_value in
  return ~undo ()
```

But the true miracle is in the combination of undoable values. Instead of defining a single `undo` function for all the big and complex scripts, present self decided to sit for one year, think very hard, write design sheets, investigate existing solutions, apply for a grant, profile prototypes, go to conferences, in order to finally write the following 8 lines of code:

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

The idea is that we define "reverted" script only for some very basic building blocks (such as changing the style, see `set_style` above), and then *combine* them, using `bind`, to revert the complex scripts. (Notice that you need to revert *first* the *last* executed script. An insane discovery.)

At this point, there are some questions you might have:
- Why a `bind` function, and not just a way to combine all undos? Something like:
  ```ocaml
  let combine undos () = List.iter (fun f -> f ()) (List.rev undos)
  ```
- How are we going to handle the syntax overhead of using all those `bind` everywhere to combine the undos?

To answer the first question, `bind` forces the computation to have an order. You have what was already computed (`x` and its side effect), and the rest of the computation (`f`). So you don't have to worry about the order:

```ocaml
let step () =
  let (), undo1 = set_style calcul Top (top + 60) in
  let (), undo2 = set_style i Top (top + 60) in
  let (), undo3 = set_style i Visibility "visible" in
  (), combine_undos [ undo3 ; undo1 ; undo2 ]
```

Oh no! In the example above, I messed up the order of undos!

But more than that, and that answers the second question, OCaml has a special syntax support to write "monadic binds" in a very natural way. If you define a function with a name starting with `let` followed by special characters, it can be applied in a specific way:

```ocaml
(* The following function application: *)
(let>) (fun x -> body) v

(* is syntactically equivalent to this: *)
let> x = v in
body
```

Interesting! So if we rename our `bind` function:

```ocaml
let (let>) f x = bind f x
```

then we can use it in our previous example:

```ocaml
let step () =
  let> () = set_style calcul Top (top + 60) in
  let> () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

This looks **exactly** like the original script, setting three style values. But in fact, there are two calls to the `bind` combining function:

```ocaml
let step () =
  bind (set_style calcul Top (top + 60)) (fun () ->
    bind (set_style i Top (top + 60)) (fun () ->
      set_style i Visibility "visible"
    )
  )
```

Which itself is equal, when "reducing" the `bind`s according to their definition:

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

which is exactly:

```ocaml
let step () =
  let (), undo1 = set_style calcul Top (top + 60) in
  let (), undo2 = set_style i Top (top + 60) in
  let (), undo3 = set_style i Visibility "visible" in
  (), (fun () -> undo3 (); undo2 (); undo1 ())
```

To me, that is crazy! Let's look again at the script:

```ocaml
let step () =
  let> () = set_style calcul Top (top + 60) in
  let> () = set_style i Top (top + 60) in
  set_style i Visibility "visible"
```

So, this piece of code, which looks exactly like a regular forward script apart from two symbols, actually returns a "reverted script", which restores the old values for each of the three style properties.

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
      (Jstr.v ".pauseAncestor") (UndoMonad.return ())
  in
  (* Find the next pause elem, if there is one *)
  match find_next_pause () with
  | None -> UndoMonad.return ()
  | Some elem ->
      (* Add the pauseAncestor class to all its parent *)
      let rec hide_parent elem =
        if Brr.El.class' (Jstr.v "universe") elem then UndoMonad.return ()
        else
          let> () = set_class "pauseAncestor" true elem in
          match Brr.El.parent elem with
          | None -> UndoMonad.return ()
          | Some elem -> hide_parent elem
      in
      hide_parent elem
```

Exactly like you would write it without the reverted script!!!!!

## Conclusion

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
