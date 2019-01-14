open Belt
open Phaser
open Utils
open GameObject

let scene = Scene.create "board"

type states = EMPTY | PLACED | NEW | LOCKED

type marble = {sprite: Sprite.sprite option; state: states}

type board_entry =
  { value: int
  ; zone: Zone.zone option
  ; graphics: Graphics.graphics option
  ; state: states
  ; sprite: Sprite.sprite option }

type player = {score: int; id: string}

let grid_w = 6

let grid_h = 6

let config : scene_config ref = init_config () |. ref

let init_marble () = {sprite= None; state= EMPTY}

let create_board_entry ?(value = 0) ?(zone = None) ?(graphics = None)
    ?(sprite = None) ?(state = EMPTY) () =
  {value; zone; graphics; state; sprite}

let has_match board_state pattern =
  let num_stones =
    Array.concatMany pattern
    |. Array.reduce 0 (fun acc slot -> if slot = 1 then acc + 1 else acc)
  in
  conv board_state pattern
  |. Array.concatMany
  |. Array.some (fun e -> e = num_stones)

let matches_any_rot board_state pattern =
  let matches_cur_board p = has_match board_state p in
  Deck_generator.get_all_rots pattern
  |. List.map matches_cur_board
  |. List.some (fun isMatch -> isMatch)

let matches_any_pattern board_state patterns =
  Array.mapWithIndex patterns (fun i pattern ->
      (i, matches_any_rot board_state pattern) )
  |. Array.keep (fun (_, hasMatch) -> hasMatch)

let modify_slot board_state position state =
  let set_cur_board x y value = set_unsafe board_state x y value in
  match state with
  | EMPTY ->
      set_cur_board position.x position.y 1 ;
      NEW
  | PLACED ->
      set_cur_board position.x position.y 0 ;
      EMPTY
  | NEW -> NEW
  | LOCKED -> LOCKED

let board =
  get_n_m_board grid_h grid_w 0
  |. map_matrix (fun _ -> create_board_entry ())

let set_board x y value = set_unsafe board x y value

let get_board x y = get_unsafe board x y

let draw_board ?(x_offset = 0.0) ?(y_offset = 0.0) w =
  let object_factor = Scene.addGet scene in
  let board_container = container object_factor in
  let grid_w_f = float_of_int grid_w in
  let grid_h_f = float_of_int grid_h in
  let s_width = w /. grid_w_f in
  let s_height = w /. grid_h_f in
  for i = 0 to int_of_float grid_w_f - 1 do
    for j = 0 to int_of_float grid_h_f - 1 do
      let slot = graphics object_factor in
      let apply f = slot |. f in
      let fillColor = get_unsafe color_map j i |. parse_int 16 in
      let s_x = float_of_int j *. s_width in
      let s_y = float_of_int i *. s_height in
      let hit_zone =
        zone object_factor
          (s_x +. (0.5 *. s_width))
          (s_y +. (0.5 *. s_height))
          s_width s_height
      in
      apply Graphics.lineStyle 5.0 0 1.0 ;
      apply Graphics.fillStyle fillColor 1.0 ;
      apply Graphics.beginPath ;
      (* draw top border if needed *)
      if i = 0 then (
        apply Graphics.moveTo s_x s_y ;
        apply Graphics.lineTo (s_x +. s_width) s_y ) ;
      (* draw right and bottom border *)
      apply Graphics.moveTo (s_x +. s_width) s_y ;
      apply Graphics.lineTo (s_x +. s_width) (s_y +. s_height) ;
      apply Graphics.lineTo s_x (s_y +. s_height) ;
      if j = 0 then apply Graphics.lineTo s_x s_y ;
      apply Graphics.fillRect
        (float_of_int j *. s_width)
        (float_of_int i *. s_height)
        s_width s_height ;
      apply Graphics.strokePath ;
      set_interactive_zone hit_zone ;
      add_container board_container (`Graphics slot) ;
      add_container board_container (`Zone hit_zone) ;
      set_board i j
        {(get_board i j) with zone= Some hit_zone; graphics= Some slot}
    done
  done ;
  Container.set_position board_container x_offset y_offset

let preload () =
  let load_image key dest =
    Scene.loadGet scene |. LoaderPlugin.image key dest
  in
  load_image "marble" "tileGrey_30.png" ;
  load_image "check" "green_checkmark.png"

let lock_slot x y = set_board x y {(get_board x y) with state= LOCKED}

let lock_row idx =
  if idx < grid_h then
    for i = 0 to grid_w - 1 do
      lock_slot i idx
    done

let lock_col idx =
  if idx < grid_w then
    for j = 0 to grid_h - 1 do
      lock_slot idx j
    done

let handle_slot_clicked () = ()

let add_board_events () =
  let add_click_callback entry =
    match entry.zone with
    | Some zone -> Zone.on zone "pointerdown" handle_slot_clicked
    | _ -> ()
  in
  for_each_matrix board add_click_callback

let restrict_board () =
  if Array.length !config.state.players < 4 then (
    grid_h - 1 |. lock_row ;
    grid_w - 1 |. lock_col ) ;
  if Array.length !config.state.players < 3 then ( lock_row 0 ; lock_col 0 )

let create_scores () =
  let object_factory = Scene.addGet scene in
  let style = Text.style ~fill:"#000" ~fontSize:"16px" in
  Array.make 5 0
  |. Array.mapWithIndex (fun idx _ ->
         text_with_style object_factory 16 (16 + (16 * idx)) "todo" style )

let draw_hand w h = 
  let padding = 20. in
  let width = w /. 5. -. padding in
  let y = 0.8 *. h in 
  let draw_card idx pattern =
    let idx_f = float_of_int idx in
    let x = width *. idx_f +. padding *. idx_f in
    Pattern_card.draw_card scene pattern x y width width in
  Array.forEachWithIndex !config.state.hand draw_card

let create () =
  let w, h =
    Scene.sysGet scene |. Scene.canvasGet
    |. fun c -> (Scene.widthGet c, Scene.heightGet c)
  in
  let board_width = w *. 0.8 in
  draw_board ~x_offset:(0.1 *. w) ~y_offset:(0.15 *. h) board_width ;
  let _ = create_scores () in
  restrict_board ();
  draw_hand w h

let handle_move {State.last_move; _} = Js.log2 "working" last_move

let init _config =
  config := _config ;
  let _ = !config.subscribe State.move_event handle_move in 
  ()

let state = State.init ()

let listeners = Map.String.empty

let () =
  Scene.initSet scene init;
  Scene.createSet scene create;
  Scene.preloadSet scene preload;
