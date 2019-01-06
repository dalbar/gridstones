open Belt


let moveAction = "MOVE"

let idAction = "ID"

let playersAction = "PLAYERS"

let turnAction = "TURN"

let gamePhaseAction = "PHASE"

let initMap () = Belt_MapString.empty

let update_state state key data =
  Belt_MapString.set state key data
 
let dispatch state listeners key data = 
  let new_state = update_state state key data in
  if Belt_MapString.has listeners key then 
    Belt_MapString.getExn listeners key |. Array.forEach (fun fn -> fn new_state);
    new_state

let subscribe listeners event fn = 
  let new_list = 
  try 
    let cur_listeners = Belt_MapString.getExn listeners event in
    Array.make 1 fn |> Array.concat cur_listeners
  with _ -> Array.make 1 fn in
  let newIndex = Array.length new_list in 
  (Belt_MapString.set listeners event new_list, newIndex)

let unsubscribe listeners event idx =
  try 
    Belt_MapString.getExn listeners event 
    |. Array.keepWithIndex (fun _ i -> i = idx )
    |> Belt_MapString.set listeners event
  with _ -> listeners

let get_value state key = Belt_MapString.getExn state key 