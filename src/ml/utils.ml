(** This module contains various utility functions outside of the actual game logic.*)
open Belt.Array

type coordinates = {x: int; y: int}

type size = {width: float; height: float}

type player = {score: int; id: string}

type scene_config =
  { state: State.state
  ; subscribe: string -> (State.state -> unit) -> int
  ; send_move: float -> float -> unit
  ; send_winner: string -> unit
  ; handle_register: unit -> unit
  ; send_start: unit -> unit }

external parse_int : string -> int -> int = "parseInt" [@@bs.val]

(** Transform between world coordinates (origin at top left corner) and image coordinates (origin at center) *)
let transform_world_to_image_coords x y canvas_width canvas_height =
  {x= (canvas_width / 2) + x; y= (canvas_height / 2) + y}

let get_n_m_board n m v = make m v |. map (make n)

let scale_marble_size board_width board_height p =
  {width= (board_width /. 6.0) -. p; height= (board_height /. 6.0) -. p}

let map_matrix_with_index matrix f =
  mapWithIndex matrix (fun j row ->
      mapWithIndex row (fun i entry -> f i j entry) )

let map_matrix matrix f =
  map_matrix_with_index matrix (fun _ _ entry -> f entry)

let for_each_matrix_with_index matrix f =
  forEachWithIndex matrix (fun j row ->
      forEachWithIndex row (fun i entry -> f i j entry) )

let for_each_matrix matrix f =
  for_each_matrix_with_index matrix (fun _ _ entry -> f entry)

let get_unsafe matrix x_ind y_ind = getExn matrix y_ind |. getExn x_ind

let set_unsafe matrix x_ind y_ind value =
  getExn matrix y_ind |. setExn x_ind value

let dot_product m1 m2 =
  let flattened_m1 = concatMany m1 in
  let flattened_m2 = concatMany m2 in
  reduce (zip flattened_m1 flattened_m2) 0. (fun acc (a, b) -> (a *. b) +. acc)

let sub_matrix m ?(x_offset = 0) ?(y_offset = 0) x_len y_len =
  let extracted_y = slice m ~offset:y_offset ~len:y_len in
  map extracted_y (fun row -> slice row ~offset:x_offset ~len:x_len)

let conv aoi filter = 
  let x_size_aoi = length aoi in 
  let y_size_aoi = length aoi.(0) in 
  let y_size = length filter in
  let x_size = length filter.(0) in
  let y_size_half = (y_size - 1) / 2 in
  let x_size_half = (x_size - 1) / 2 in
  map_matrix_with_index aoi (fun i j _ -> 
          if i - x_size_half < 0 || j - y_size_half < 0 || i + x_size_half = x_size_aoi || j + y_size_half = y_size_aoi then 0.
          else (
            sub_matrix aoi ~x_offset:(i - x_size_half)
              ~y_offset:(j - y_size_half) x_size y_size
            |. dot_product filter )
  )
let color_map =
  let res = make 6 "42a5f5" |. map (make 6) in
  let set_color x y =
    match (x, y, x < 5, y < 5) with
    | 0, _, true, true -> res.(x).(y) <- "fdd835"
    | _, 0, true, true -> res.(x).(y) <- "fdd835"
    | _, 5, _, _ -> res.(x).(y) <- "ff5722"
    | 5, _, _, _ -> res.(x).(y) <- "ff5722"
    | _ -> res.(x).(y) <- "42a5f5"
  in
  forEachWithIndex res (fun y rows ->
      forEachWithIndex rows (fun x _ -> set_color x y) ) ;
  res

let get_board_idx x y grid_h = (y *. grid_h) +. x


let init_config ?(state = State.init ()) ?(subscribe = fun _ _ -> -1)
    ?(send_move = fun _ _ -> ()) ?(send_winner = fun _ -> ())
    ?(handle_register = fun () -> ()) ?(send_start = fun () -> ()) () =
  {state; subscribe; send_move; send_winner; handle_register; send_start}
