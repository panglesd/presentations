type 'a undoable = 'a * (unit -> unit)

let return ?(undo = fun () -> ()) x = (x, undo)

let bind x f =
  let (x, undo1) = x in
  let (y, undo2) = f x in
  let undo () = (* _TODO_ *) undo2 () ; undo1 ()  in
  return ~undo x

let style = ref ""

let set_style new_value =
  Format.printf "Setting style from \"%s\" to \"%s\"\n%!" !style new_value;
  style := new_value

let () = set_style "initial"

let set_style_u new_value =
  let old_value = !style in
  set_style new_value;
  let undo () = set_style (* _TODO_ *) old_value in
  return ~undo ()

let (let*) = bind

let (), undo =
  let* () = set_style_u "visible" in
  let* () = set_style_u "invisible" in
  let* () = set_style_u "red" in
  return ()


let () = undo ()
