open Board_utils
open Belt_Array
open Belt
open Deck_generator

type states = EMPTY | PLACED | NEW | LOCKED

let has_match board_state pattern =
  let num_stones =
    concatMany pattern
    |. reduce 0 (fun acc slot -> if slot = 1 then acc + 1 else acc)
  in
  Board_utils.conv board_state pattern
  |. concatMany
  |. some (fun e -> e = num_stones)

let matches_any_rot board_state pattern =
  let matches_cur_board p = has_match board_state p in
  get_all_rots pattern |. List.map matches_cur_board
  |. List.some (fun isMatch -> isMatch)

let matches_any_pattern board_state patterns =
  mapWithIndex patterns (fun i pattern ->
      (i, matches_any_rot board_state pattern) )
  |. keep (fun (_, hasMatch) -> hasMatch)

let modify_slot board_state position state =
  let set_cur_board x y value = Utils.set_unsafe board_state x y value in
  match state with
  | EMPTY ->
      set_cur_board position.x position.y 1 ;
      NEW
  | PLACED ->
      set_cur_board position.x position.y 0 ;
      EMPTY
  | NEW -> NEW
  | LOCKED -> LOCKED
