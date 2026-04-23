include Map.S with type key := int
(** @closed *)

module Map : module type of Map.Make (Int)
