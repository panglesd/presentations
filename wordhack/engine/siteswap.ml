open Brr

type ball = El.t
type hand = Left | Right

let other_hand = function Left -> Right | Right -> Left

type point = float * float

type ball_state = {
  ball : ball;
  mutable position : point;
  offset : point;
  mutable catch_pos : point;
  mutable throw_pos : point;
  mutable target_pos : point;
  mutable total_time : float;
}

let set_position (ball_state : ball_state) position =
  let { ball; offset; _ } = ball_state in
  let x = fst position -. fst offset in
  let y = snd position -. snd offset in
  let style =
    let open Jstr in
    v "translate(" + of_float x + v "px," + of_float y + v "px)"
  in
  El.set_inline_style (Jstr.v "transform") style ball;
  ball_state.position <- position

type timing = Empty | Ball of ball_state

module Ring = struct
  type 'a t = { array : 'a Array.t; mutable index : int; length : int }

  let create array =
    let index = 0 and length = Array.length array in
    { array; index; length }

  let get x n = x.array.((x.index + n) mod x.length)

  let pop x =
    let index = x.index in
    let head = x.array.(index) in
    x.index <- (index + 1) mod x.length;
    head

  let pop_reset x default =
    let index = x.index in
    let head = x.array.(index) in
    x.array.(index) <- default;
    x.index <- (index + 1) mod x.length;
    head

  let set x n v = x.array.((x.index + n) mod x.length) <- v

  let foldi f acc x =
    let acc = ref acc in
    for i = 0 to x.length - 1 do
      acc := f i !acc (get x i)
    done;
    !acc
end

type state = {
  mutable timer : float;
  mutable beat_count : int;
  state : timing Ring.t;
  siteswap : int Ring.t;
}

let gravity = 0.00045
let step_time = 600.

type action = Throw | Catch

let hand_position hand mode =
  let x_base = match hand with Left -> -150. | Right -> 150. in
  let offset =
    match (hand, mode) with
    | Left, Throw -> 30.
    | Right, Throw -> -30.
    | Left, Catch -> -30.
    | Right, Catch -> 30.
  in
  (x_base +. offset, 300.)

(* --- UPDATED PHYSICS: BÉZIER SCOOP --- *)
let dwell_ratio = 0.3
let scoop_depth = 80. (* How far down the hand dips in pixels *)

(* Quadratic Bézier formula: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2 *)
let bezier p0 p1 p2 t =
  let x0, y0 = p0 and x1, y1 = p1 and x2, y2 = p2 in
  let mt = 1. -. t in
  let mt2 = mt *. mt in
  let t2 = t *. t in
  let x = (mt2 *. x0) +. (2. *. mt *. t *. x1) +. (t2 *. x2) in
  let y = (mt2 *. y0) +. (2. *. mt *. t *. y1) +. (t2 *. y2) in
  (x, y)

let interpolate_pos b time_remaining =
  let total = b.total_time in
  let elapsed = total -. time_remaining in
  let dwell_duration = step_time *. dwell_ratio in

  if elapsed < dwell_duration then
    (* --- DWELL PHASE: Curved scoop using Bézier --- *)
    let t = elapsed /. dwell_duration in
    (* Normalized time 0.0 -> 1.0 *)
    let p0 = b.catch_pos in
    (* Start *)
    let p2 = b.throw_pos in
    (* End *)

    (* Calculate Control Point (P1) *)
    (* X is midpoint between catch and throw *)
    let p1_x = (fst p0 +. fst p2) /. 2. in
    (* Y is below the lowest point of catch/throw to create the dip *)
    let base_y = max (snd p0) (snd p2) in
    let p1_y = base_y +. scoop_depth in
    let p1 = (p1_x, p1_y) in

    bezier p0 p1 p2 t
  else
    (* --- FLIGHT PHASE: Standard Parabola --- *)
    let flight_duration = total -. dwell_duration in
    let flight_elapsed = elapsed -. dwell_duration in
    let t = flight_elapsed /. flight_duration in

    let sx, sy = b.throw_pos in
    let ex, ey = b.target_pos in

    let cur_x = sx +. ((ex -. sx) *. t) in
    let base_y = sy +. ((ey -. sy) *. t) in

    let h_offset =
      0.5 *. gravity *. flight_elapsed *. (flight_duration -. flight_elapsed)
    in
    (cur_x, base_y -. h_offset)
(* ------------------------------------- *)

let update_view state delta_time =
  Ring.foldi
    (fun i () slot ->
      match slot with
      | Empty -> ()
      | Ball b ->
          let time_remaining = state.timer +. (float_of_int i *. step_time) in
          let new_pos = interpolate_pos b time_remaining in
          set_position b new_pos)
    () state.state

let next state time_spent =
  state.timer <- state.timer -. time_spent;

  if state.timer < 0. then (
    state.timer <- state.timer +. step_time;
    state.beat_count <- state.beat_count + 1;

    let ball_opt = Ring.pop_reset state.state Empty in
    let throw_height = Ring.pop state.siteswap in

    match (ball_opt, throw_height) with
    | Empty, _ -> ()
    | Ball b, n ->
        let current_hand = if state.beat_count mod 2 = 1 then Right else Left in
        let target_hand_idx = state.beat_count + n in
        let target_hand = if target_hand_idx mod 2 = 1 then Right else Left in

        b.catch_pos <- hand_position current_hand Catch;
        b.throw_pos <- hand_position current_hand Throw;
        b.target_pos <- hand_position target_hand Catch;
        b.total_time <- float_of_int n *. step_time;

        if n > 0 then Ring.set state.state (n - 1) (Ball b))
  else ();

  update_view state time_spent

let siteswap = Ring.create [| 5; 3; 1 |]
let now () = Performance.now_ms G.performance

let loop () =
  let timing =
    let dummy_pos = (0., 0.) in
    let create_ball ?(offset = (0., 0.)) id =
      let el =
        match El.find_first_by_selector (Jstr.v id) with
        | Some e -> e
        | None ->
            Brr.Console.(log [ "ARGH" ]);
            let e = El.div [] in
            El.set_inline_style (Jstr.v "position") (Jstr.v "absolute") e;
            El.set_inline_style (Jstr.v "width") (Jstr.v "20px") e;
            El.set_inline_style (Jstr.v "height") (Jstr.v "20px") e;
            El.set_inline_style (Jstr.v "background") (Jstr.v "red") e;
            El.set_inline_style (Jstr.v "border-radius") (Jstr.v "50%") e;
            El.append_children
              (El.find_first_by_selector (Jstr.v "body") |> Option.get)
              [ e ];
            e
      in
      Ball
        {
          ball = el;
          position = offset;
          offset;
          catch_pos = dummy_pos;
          throw_pos = dummy_pos;
          target_pos = dummy_pos;
          total_time = 1.;
        }
    in
    Ring.create
      [|
        create_ball ~offset:(-200., 0.) "#id249847994";
        create_ball ~offset:(200., 0.) "#id409218438";
        create_ball ~offset:(100., 400.) "#id256822448";
        Empty;
        Empty;
      |]
  in
  let state = { timer = 0.; beat_count = 0; state = timing; siteswap } in

  let rec update old_now now =
    let dt = min (now -. old_now) 100. in
    next state dt;
    let _ = G.request_animation_frame (update now) in
    ()
  in
  let _ = G.request_animation_frame (update (now ())) in
  ()

let () =
  let start _ = loop () in
  Jv.set Jv.global "startLoop" (Jv.callback ~arity:1 start)
