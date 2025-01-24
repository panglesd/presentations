# "Rewrite it in OCaml"

A bit more than three years ago, I was having my first job interview as a software developer. I had to choose and send a snippet of code I authored, as a basis for discussion.

But first, let me introduce you my past self. He was very... young and enthusiastically inexperimented. His programming was fast and furious. He was also so innocent: he had no users on any of his project.

The company is Tarides, which focus is on the OCaml programming language, and so past-self sent... the messiest Javascript function for a project we (past-self and I) are excited about, Slipshow. It represented past self quite well: it was an unmaintainable solution that he had quickly hacked to face a difficult problem, and it worked brittly well.

My past-self enthusiasm must have hacked the interviewer's brain, since I did get the job. Or, it is better to be excited about a project you did than to show clean code. Anyway, probably as a desperate attempt to return to safer grounds, he asked the only good question you can ask on such Javascript code:

> How would you rewrite that in OCaml?

I completely forgot what I answered. However, after three years of OCaml training, 2 Mirage retreat, 2 months of unpaid leaves focusing on exactly that, and an NLNet grant, I can now answer you, Jon. I have a very elegant way of rewriting that in OCaml.

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
It can be seen as a glorified script scheduler: For instance, suppose it's a normal day, and you are making a presentation on... Infinite Computations in Algorithmic randomness and Reverse Mathematics. (If that does not speak to you, the recipe for an appli pie work, but I like this historical example)

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

Works well enough!

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
type 'a undoable = 'a * (unit -> unit)
(** An undoable value is just a value and a function to revert the side-effects triggered when computing it *)
```






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
