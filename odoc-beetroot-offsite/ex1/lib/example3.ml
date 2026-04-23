module type S = sig
  type t

  val compare : t -> t -> int
end

type t = int



module Map = Map.Make (Example2.M)
