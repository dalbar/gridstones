open Board_utils
open Belt_Array

type aoi = { min_x: int; min_y: int; max_x: int; max_y: int}
type slot_value = SET | EMPTY
  type action = PLACE | REMOVE

type move = { action: action; position: Board_utils.coordinates}

let area_of_interest position grid_size =
  let zero_cap x = max x 0 in 
 { 
  min_x = zero_cap @@ position.x - grid_size;
  min_y = zero_cap @@ position.y - grid_size; 
  max_x = zero_cap @@ position.x + grid_size;
  max_y = zero_cap @@ position.y + grid_size }  

let has_match board_state pattern = 
  let num_stones = concatMany pattern |. reduce 0 (fun acc slot -> if slot = 1 then acc + 1 else acc) in
  Board_utils.conv board_state pattern |. concatMany |. some (fun e -> e = num_stones)

let matches_any_pattern board_state patterns = 
  mapWithIndex patterns (fun i pattern -> ( i, has_match board_state pattern)) |. keep (fun (_, hasMatch) ->  hasMatch)
  
let modify_slot board_state position value = 
  board_state.(position.y).(position.x) <- value

let pattern1 = 
  let p1 = make 3 (-1) |. map (make 3) in
  p1.(0).(0) <- 1;
  p1.(0).(2) <- 1;
  p1.(2).(0) <- 1;
  p1
