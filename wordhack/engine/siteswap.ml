type ball = Brr.El.t
type hand = Left | Right

let other_hand = function Left -> Right | Right -> Left

(* type landing = { hand : hand; time : float } *)
type ball_state = {
  ball : ball;
  position : float * float (* ; landing : landing *);
}

type timing = Empty | Ball of ball_state

module Ring = struct
  type 'a t = { array : 'a Array.t; mutable index : int; length : int }

  let create array =
    let index = 0 and length = Array.length array in
    { array; index; length }

  let pop x =
    let index = x.index in
    let head = x.array.(index) in
    x.index <- (index + 1) mod x.length;
    head

  let set x n v = x.array.((x.index + n) mod x.length) <- v
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

let hand_position = function Left -> (_ : float * float) | Right -> _

let place hand n time delta_time (current_x, current_y) =
  let hand = if n mod 2 = 0 then hand else other_hand hand in
  let target_x, target_y = hand_position hand in
  let x = linear_interpolate current_x target_x time delta_time in
  let y = square_interpolate current_y target_y time delta_time in
  (x, y)

let next state time_spent =
  state.timer <- state.timer -. time_spent;
  if state.timer < 0. then
    let ball = Ring.pop state.state in
    let number = Ring.pop state.siteswap in
    match (ball, number) with
    | Empty, 0 -> ()
    | (Ball _ as b), n when n > 0 -> Ring.set state.state n b
    | _ -> assert false
  else ()

let siteswap = Ring.create [| 4; 4; 1 |]

let timing =
  let position = assert false and ball = assert false in
  Ring.create
    [|
      Ball { position; ball }; Ball { position; ball }; Ball { position; ball };
    |]

let now () = assert false
let nextFrame _ = assert false

let loop () =
  let state = { timer = 0.; state = timing; siteswap } in

  let rec update old_now now =
    next state (now -. old_now);
    nextFrame (update now)
  in
  nextFrame (update (now ()))
