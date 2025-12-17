type ball = Brr.El.t
type hand = Left | Right

let other_hand = function Left -> Right | Right -> Left

(* type landing = { hand : hand; time : float } *)
type ball_state = {
  ball : ball;
  mutable position : float * float (* ; landing : landing *);
  offset : float * float;
}

let set_position (ball_state : ball_state) position =
  let { ball; position = _; offset } = ball_state in
  let x = fst position -. fst offset in
  let y = snd position -. snd offset in
  let style =
    let open Jstr in
    v "translate(" + Jstr.of_float x + v "px," + Jstr.of_float y + v "px)"
  in
  Brr.Console.(log [ style ]);
  Brr.El.set_inline_style (Jstr.v "transform") style ball;
  ball_state.position <- (x, y)

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
  state : timing Ring.t;
  siteswap : int Ring.t;
}

(* acc = -g
   v = -gt
   p = -(g/2)t^2

   At time 0, y = current_y
   At time t, y = target_y
   y = -g*t^2 + X t + current_y = target_y
   =>
   X = (target_y - current_y + gt^2) / t

   y = -g*delta_t^2 + (target_y - current_y + gt^2) / t delta_t + current_y
   
*)

let linear_interpolate current_x target_x time delta_time =
  current_x +. ((target_x -. current_x) *. delta_time /. time)

let g = 10.

let square_interpolate current_y target_y t delta_t =
  ((0. -. g) *. (delta_t *. delta_t))
  +. ((target_y -. current_y +. (g *. t *. t)) /. t *. delta_t)
  +. current_y

let hand_position = function
  | Left -> ((500., 500.) : float * float)
  | Right -> ((500., 500.) : float * float)

let place hand n time delta_time (current_x, current_y) =
  let hand = if n mod 2 = 0 then hand else other_hand hand in
  let target_x, target_y = hand_position hand in
  let x = linear_interpolate current_x target_x time delta_time in
  let y = square_interpolate current_y target_y time delta_time in
  (x, y)

let step_time = 1000.

let update_view state delta_time =
  let () =
    Ring.foldi
      (fun i () ball ->
        match ball with
        | Empty -> ()
        | Ball ball_state ->
            let new_position =
              let ( !! ) = float_of_int in
              place Left 0
                ((!!i *. step_time) +. state.timer)
                delta_time ball_state.position
            in
            set_position ball_state new_position)
      () state.state
  in
  ()

let next state time_spent =
  state.timer <- state.timer -. time_spent;
  if state.timer < 0. then (
    Brr.Console.(log [ "Activated step" ]);
    state.timer <- state.timer +. step_time;
    let ball = Ring.pop state.state in
    let number = Ring.pop state.siteswap in
    match (ball, number) with
    | Empty, 0 -> ()
    | (Ball _ as b), n when n > 0 -> Ring.set state.state n b
    | _ -> assert false)
  else ();
  update_view state time_spent

let siteswap = Ring.create [| 4; 4; 1 |]

let timing =
  Ring.create
    [|
      Ball
        {
          position = (10., 10.);
          ball = Brr.El.find_first_by_selector (Jstr.v "#id1") |> Option.get;
          offset = (100., 100.);
        };
      Ball
        {
          position = (100., 100.);
          ball = Brr.El.find_first_by_selector (Jstr.v "#id2") |> Option.get;
          offset = (100., 100.);
        };
      Ball
        {
          position = (100., 100.);
          ball = Brr.El.find_first_by_selector (Jstr.v "#id3") |> Option.get;
          offset = (100., 100.);
        };
    |]

let now () = Brr.Performance.now_ms Brr.G.performance

let loop () =
  let state = { timer = 0.; state = timing; siteswap } in

  let rec update old_now now =
    next state (now -. old_now);
    let _ = Brr.G.request_animation_frame (update now) in
    ()
  in
  let _ = Brr.G.request_animation_frame (update (now ())) in
  ()

let () = loop ()
