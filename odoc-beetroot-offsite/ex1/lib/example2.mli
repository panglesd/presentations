module M : sig
  type t

  val compare : t -> t -> int
end

val y : M.t
