module Example1 = Ex0
module Example2 = Example2
module Example3 = Example3

val x : int
(** The most common integer *)

type tt
(** This type is twice as [t] as usual *)

val f : tt -> tt
(** [f x] applies [f] on [x]. *)

module M : sig
  type t

  val compare : t -> t -> int
end

val y : M.t

include module type of M with type t = int
module Map : module type of Map.Make (M)
