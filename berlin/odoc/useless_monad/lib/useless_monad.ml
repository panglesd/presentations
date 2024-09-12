module Monad = struct
  type 'a t = 'a

  let t = ()
  let map x f = f x
  let bind x f = f x
  let return x = x
end

module Fun = struct
  type t

  let apply x f = f x
  let unapply _x = failwith "TODO"
end

module SuperFun = struct
  include Fun

  let apply2 x y f = f x y
end
