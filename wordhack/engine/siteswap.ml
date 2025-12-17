open Brr

type ball = El.t
type hand = Left | Right

let other_hand = function Left -> Right | Right -> Left

type point = float * float

type ball_state = {
  ball : ball;
  mutable position : point;
  offset : point;
  mutable origin : point;
  mutable target : point;
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

(* --- FIXED RING MODULE --- *)
module Ring = struct
  type 'a t = { array : 'a Array.t; mutable index : int; length : int }

  let create array =
    let index = 0 and length = Array.length array in
    { array; index; length }

  let get x n = x.array.((x.index + n) mod x.length)

  (* Standard pop: just returns the value and advances. 
     Used for Siteswap (which loops forever). *)
  let pop x =
    let index = x.index in
    let head = x.array.(index) in
    x.index <- (index + 1) mod x.length;
    head

  (* Pop and Reset: Returns value, overwrites slot with [default], and advances.
     Used for Timing (to clear the slot after a ball leaves). *)
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
(* ------------------------- *)

type state = {
  mutable timer : float;
  mutable beat_count : int;
  state : timing Ring.t;
  siteswap : int Ring.t;
}

let gravity = 0.00025
let step_time = 600.
let hand_position = function Left -> (-150., 300.) | Right -> (150., 300.)

let interpolate_pos start_pt end_pt progress total_dur =
  let sx, sy = start_pt in
  let ex, ey = end_pt in
  let cur_x = sx +. ((ex -. sx) *. progress) in
  let base_y = sy +. ((ey -. sy) *. progress) in
  let t = progress *. total_dur in
  let height_offset = 0.5 *. gravity *. t *. (total_dur -. t) in
  (cur_x, base_y -. height_offset)

let update_view state delta_time =
  Ring.foldi
    (fun i () slot ->
      match slot with
      | Empty -> ()
      | Ball b ->
          let time_remaining = state.timer +. (float_of_int i *. step_time) in
          let progress = 1.0 -. (time_remaining /. b.total_time) in
          let new_pos =
            interpolate_pos b.origin b.target progress b.total_time
          in
          set_position b new_pos)
    () state.state

(* --- FIXED NEXT FUNCTION --- *)
let next state time_spent =
  state.timer <- state.timer -. time_spent;

  if state.timer < 0. then (
    state.timer <- state.timer +. step_time;
    state.beat_count <- state.beat_count + 1;

    (* Use pop_reset for balls (to clear the buffer) *)
    let ball_opt = Ring.pop_reset state.state Empty in
    (* Use standard pop for siteswap (integers just loop) *)
    let throw_height = Ring.pop state.siteswap in

    match (ball_opt, throw_height) with
    | Empty, _ -> ()
    | Ball b, n ->
        let current_hand = if state.beat_count mod 2 = 1 then Right else Left in
        let target_hand_idx = state.beat_count + n in
        let target_hand = if target_hand_idx mod 2 = 1 then Right else Left in

        b.origin <- hand_position current_hand;
        b.target <- hand_position target_hand;
        b.total_time <- float_of_int n *. step_time;

        if n > 0 then Ring.set state.state (n - 1) (Ball b))
  else ();

  update_view state time_spent
(* --------------------------- *)

let siteswap = Ring.create [| 4; 4; 1 |]

let timing =
  let dummy_pos = (0., 0.) in
  let create_ball id =
    let el =
      match El.find_first_by_selector (Jstr.v id) with
      | Some e -> e
      | None ->
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
        position = dummy_pos;
        offset = (10., 10.);
        origin = dummy_pos;
        target = dummy_pos;
        total_time = 1.;
      }
  in
  Ring.create
    [|
      create_ball "#id1"; create_ball "#id2"; create_ball "#id3"; Empty; Empty;
    |]

let now () = Performance.now_ms G.performance

let loop () =
  let state = { timer = 0.; beat_count = 0; state = timing; siteswap } in

  let rec update old_now now =
    let dt = min (now -. old_now) 100. in
    next state dt;
    let _ = G.request_animation_frame (update now) in
    ()
  in
  let _ = G.request_animation_frame (update (now ())) in
  ()

let () = loop ()
