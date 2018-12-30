(** This module contains various utility functions outside of the actual game logic.*)

open Belt_Array 
open Js_console

type coordinates = { x: int; y: int}
type size = { width: float; height: float}
 
(** Transform between world coordinates (origin at top left corner) and image coordinates (origin at center) *)
let transform_world_to_image_coords x y canvas_width canvas_height = {x = canvas_width/2 + x; y = canvas_height / 2 + y}

let get_n_m_board n m = make m 0 |. map (make n)

let scale_marble_size board_width board_height ?padding:(p = 0.0) = { width = board_width /. 6.0 -. p; height = board_height /. 6.0 -. p }

let dot_product m1 m2 =
  let flattened_m1 = concatMany m1 in 
  let flattened_m2 = concatMany m2 in
  reduce (zip flattened_m1 flattened_m2)  0 (fun acc (a, b) -> a * b + acc)

let sub_matrix m ?(x_offset=0)  ?(y_offset=0) x_len y_len = 
  let extracted_y = slice m ~offset:y_offset ~len:y_len in
  map extracted_y (fun row -> slice row ~offset:x_offset ~len:x_len)
  
let conv aoi filter = 
  let y_size = length filter in 
  let x_size = length filter.(0) in 
  let y_size_half = (y_size - 1)/2 in 
  let x_size_half = (x_size - 1)/2 in
  mapWithIndex aoi (fun i row -> 
    mapWithIndex row (fun j _ -> if i - y_size_half < 0|| j - x_size_half < 0 then 0 
      else sub_matrix aoi ~x_offset:(j-x_size_half) ~y_offset:(i - y_size_half) x_size y_size |. dot_product filter ) 
  )

let color_map =
  let res = make 6 "42a5f5" |. map (make 6) in 
  let set_color x y = 
    match x, y, x < 5, y < 5 with 
    | 0, _, true, true -> res.(x).(y) <- "fdd835"
    | _, 0, true, true -> res.(x).(y) <- "fdd835"
    | _, 5, _, _ -> res.(x).(y) <- "ff5722"
    | 5, _, _, _ ->  res.(x).(y) <- "ff5722"
    | _ -> res.(x).(y) <- "42a5f5" in 
  forEachWithIndex res
    (fun y rows -> forEachWithIndex rows (fun x _ -> set_color x y));
  res
