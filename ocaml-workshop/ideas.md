# Ideas of what to speak of

## Commit 1: A runtime in Javascript

## Commit 2: A compiler in OCaml

Thank you OCaml.

Thank you `cmarkit`. Thank you `cmdliner`.

Thank you `grace`.

Introduced CMarkit. Extensible abstract data types.

Reached a blocker: Compiler was going well. Runtime was not, and very hard to extend or even maintain.

## Commit 3: Rewriting it in OCaml

Thank you `dune`. Thank you `js_of_ocaml`.

The build system:
- A `.js` file is built
- This `.js` file is in the dependency of the server
- A `ppx_blob` includes it in the compiler

The runtime was also improved a lot (see my talk on the Undo monad)

## Commit 4: Draw your presentation

Thank you `lwd`.

## Commit 5: LSP server

Thank you `linol`. Thank you `dream.` Thank you `ppx_deriving`.

The dependencies:

```
x ocaml
x cmarkit
x dune
x lwd
x grace
x cmdliner
x js_of_ocaml
x dream
x ppx_blob
x ppx_sexp_conv
x ppx_deriving_yojson
x linol
```

# Commits

## Fixing "previous" in the javascript era

┌─────────┬────────────┬─────────────────────────────────────────────────────────────────────┐
│ Commit  │    Date    │                               Message                               │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 436bb65 │ 2020-01-06 │ implemented engine.previousSlip ← the feature is born               │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ d0cfc69 │ 2020-01-08 │ corrected "not coming beginning on previous" bug                    │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 61e6cb7 │ 2020-01-08 │ corrected "future slip, delay not 0 again when previousing" bug     │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 3af56a3 │ 2020-03-12 │ corrected horribug previous                                         │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 6f9b31d │ 2020-03-12 │ update counter on previous                                          │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ bcd8323 │ 2020-03-22 │ better previous: use delay from previous state (and many debug log) │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 28372cd │ 2021-06-30 │ two bugs in previous and annotations                                │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 7922ce1 │ 2021-07-12 │ debug on previous                                                   │
├─────────┼────────────┼─────────────────────────────────────────────────────────────────────┤
│ 2437301 │ 2021-07-20 │ correcting bug with "previous" and "resizeObserver"                 │
└─────────┴────────────┴─────────────────────────────────────────────────────────────────────┘

## The commits

  ┌─────┬─────────────────┬─────────┬─────────────────────────────────────────────────┐
  │  #  │      Topic      │ Commit  │                     Message                     │
  ├─────┼─────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ 1   │ JS runtime      │ d90331a │ tree-ToC qui marche trop bien !!!               │
  ├─────┼─────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ 2   │ OCaml compiler  │ 0fa489e │ Adding the compiler                             │
  ├─────┼─────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ 3   │ OCaml runtime   │ 32d0917 │ BOOOOOOOOOOOOOOOMM! (Undo monad, they work 🤯)  │
  ├─────┼─────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ 4   │ Record & replay │ f5e63ca │ Record and replay your drawings                 │
  ├─────┼─────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ 5   │ LSP server      │ 1d9d960 │ Initial simple lsp server with only diagnostics │
  └─────┴─────────────────┴─────────┴─────────────────────────────────────────────────┘

## Alternatives


  ┌─────────┬────────────┬────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────┐
  │ Commit  │    Date    │                    Message                     │                                           Vibe                                            │
  ├─────────┼────────────┼────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
  │ e568193 │ 2026-05-15 │ "LSP: actually openings of new files already   │ Delightful "oh — it already works!" surprise. Matches your "that was easy" energy         │
  │         │            │ work"                                          │ perfectly.                                                                                │
  ├─────────┼────────────┼────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
  │ 0e34aa8 │ 2026-04-10 │ "LSPishow: Proof of concept for jump to def"   │ A satisfying "it works!" milestone — go-to-definition in your slide source is a great     │
  │         │            │                                                │ thing to demo live.                                                                       │
  ├─────────┼────────────┼────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
  │ c62c93f │ 2026-05-16 │ "Make lspishow a subcommand of slipshow"       │ The moment it becomes a real user-facing command; keeps the lspishow pun (LSP +           │
  │         │            │                                                │ slipshow).                                                                                │
  ├─────────┼────────────┼────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────┤
  │ f62e62d │ 2026-05-21 │ "LSPishow: Add an LSP server for slipshow"     │ Clean landmark, also carries the pun.                                                     │
  │         │            │ (merge #229)                                   │                                                                                           │
  └─────────┴────────────┴────────────────────────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────┬────────────┬─────────────────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────────────┐
  │ Commit  │    Date    │                       Message                       │                                     Why it pops                                      │
  ├─────────┼────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
  │ 156f57d │ 2025-11-25 │ "I'm on the right track (pun)"                      │ A deliberate pun — a recording is a track. Playful and perfectly on-theme for a      │
  │         │            │                                                     │ drawings-recording slide.                                                            │
  ├─────────┼────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
  │ cacb776 │ 2025-11-25 │ "Bouquet final for pauses in recordings"            │ "Grand finale" — celebratory, marks the feature coming together (this was my earlier │
  │         │            │                                                     │  alt).                                                                               │
  ├─────────┼────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
  │ f86f4fb │ 2025-11-18 │ "More progress. Don't look at the git history, it's │ Self-deprecating and funny — great if you want to show the messy grind behind a      │
  │         │            │  the worst!"                                        │ slick feature.                                                                       │
  ├─────────┼────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
  │ d71a51f │ 2025-11-25 │ "Rename live_coding, that was not serious"          │ Cheeky.                                                                              │
  ├─────────┼────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────┤
  │ 06af5e3 │ 2025-11-25 │ "Announce that a feature is planned instead of      │ Honest and funny.                                                                    │
  │         │            │ implementing it"                                    │                                                                                      │
  └─────────┴────────────┴─────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────────────┘



  ┌───────────────┬────────────────────────────────────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────────┐
  │    Commit     │                            Message                             │                                 Why it's great                                  │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 55ef63b       │ Toutétutétu                                                    │ Cryptic French mush ("tout est foutu" — everything's screwed — mashed into      │
  │               │                                                                │ gibberish). Wonderfully mysterious.                                             │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 0361601       │ Fix weak variable that was supposed to be sgroumphed           │ Invented verb "sgroumphed." Peak personal jargon.                               │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ f20dd79 →     │ Does not work............. → then works                        │ The despair of the trailing dots, resolved one commit later by a curt "works."  │
  │ next          │                                                                │ A perfect two-panel comic.                                                      │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ d5b8459       │ Go Lambdaconf!                                                 │ Committed live at a conference — pure enthusiasm.                               │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 21cea99 /     │ Making progress before autodestruction / Initiating            │ Dramatic self-destruct sequence for a refactor.                                 │
  │ b30fb44       │ auto-destruction                                               │                                                                                 │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ cebf30c       │ Add a test, because yes, I'm doing TDD!                        │ Defensive, self-aware, delightful.                                              │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ da78a1a       │ Committing things before my laptop break!                      │ Human panic — save before it dies.                                              │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 6c9ab41 / 278 │ Fix nitpicks from an artificial mind / "…review comments made  │ Poetic euphemism for AI review.                                                 │
  │               │ by an artificial mind…"                                        │                                                                                 │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 88e5761       │ More review psychosis                                          │ Relatable.                                                                      │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 286318b       │ Remove spurious "Yo"                                           │ A stray "Yo" made it into the code.                                             │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ e355fe8       │ more gnomes                                                    │ Zero context. Excellent.                                                        │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ e23a4ec       │ Avoid detonating a hurry bomb several times                    │ "Hurry bomb" — great internal terminology.                                      │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 762241c /     │ Fix fix / Fix the folder fix                                   │ Recursive fixing.                                                               │
  │ 66bc9fa       │                                                                │                                                                                 │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 0a59bfc       │ reluctantly adding immediate-enter, to be renammed...          │ Audible sigh.                                                                   │
  ├───────────────┼────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────┤
  │ 7e8ca4d       │ unexpectedly fast introduction of atrament                     │ Pleasant-surprise energy.                                                       │
  └───────────────┴────────────────────────────────────────────────────────────────┴─────────────────────────────────────────────────────────────────────────────────┘

  32d0917 BOOOOOOOOOOOOOOOMM! · f86f4fb Don't look at the git history, it's the worst! · 156f57d I'm on the right track (pun) · 3af56a3 corrected horribug previous ·
  07020eb Push the joke to the donation button · d90331a tree-ToC qui marche trop bien !!! · 3ac99e3 Wo so cool lwd · cacb776 Bouquet final for pauses in recordings


  ┌─────────┬─────────────────────────────────────────────────────────┐
  │ Commit  │                         Message                         │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ 32d0917 │ BOOOOOOOOOOOOOOOMM! (body: "Undo monad, they work 🤯")  │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ d90331a │ tree-ToC qui marche trop bien !!! ("works too well!!!") │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ 3ac99e3 │ Wo so cool lwd                                          │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ cacb776 │ Bouquet final for pauses in recordings                  │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ 4a26a66 │ Finally working beginning                               │
  ├─────────┼─────────────────────────────────────────────────────────┤
  │ f37226f │ Finally understood the pull model                       │
  └─────────┴─────────────────────────────────────────────────────────┘

  ┌───────────────────┬───────────────────────────────────────────────────────────────┐
  │      Commit       │                            Message                            │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ f86f4fb           │ More progress. Don't look at the git history, it's the worst! │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ d71a51f           │ Rename live_coding, that was not serious                      │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ 1769ead           │ Another embarrassing error                                    │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ fa061d2 / ff08ce2 │ Fix horrible mistake / Changelog for horrible mistake         │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ fc5c95d           │ Horribly non-atomic commit                                    │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ 06af5e3           │ Announce that a feature is planned instead of implementing it │
  ├───────────────────┼───────────────────────────────────────────────────────────────┤
  │ a78a533           │ Woops · 744469b oops I forgot babel conf file                 │
  └───────────────────┴───────────────────────────────────────────────────────────────┘

  ┌─────────┬─────────────────────────────────────────────────────────────────┐
  │ Commit  │                             Message                             │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ 156f57d │ I'm on the right track (pun)                                    │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ 3af56a3 │ corrected horribug previous ("horrible" + "bug")                │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ 07020eb │ Push the joke to the donation button                            │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ f22ccb8 │ "Final?" refactoring for drawing events… (the skeptical quotes) │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ dc9dc0d │ Hurry when suddenly fast when drawing                           │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ bb2707c │ Quick win on one line                                           │
  ├─────────┼─────────────────────────────────────────────────────────────────┤
  │ 6fa2cff │ Found 0 vulnerabilities!                                        │
  └─────────┴─────────────────────────────────────────────────────────────────┘

  1. 32d0917 — "BOOOOOOOOOOOOOOOMM!" — the most explosive, pure joy.
  2. f86f4fb — "Don't look at the git history, it's the worst!" — the funniest confession; perfect meta-joke for a talk that literally shows the git history.
  3. 156f57d — "I'm on the right track (pun)" — best deliberate wordplay.
  4. 3af56a3 — "corrected horribug previous" — best accidental coinage.
  5. 07020eb — "Push the joke to the donation button" — intriguing; makes people want to know what the joke was.
