module Exemple1 = Ex0

let x = 5

type tt = A of int

let f (A _) = A 0

module M = struct
  type t = int

  let compare = compare
end

let y = 5

include M
module Map = Map.Make (M)
