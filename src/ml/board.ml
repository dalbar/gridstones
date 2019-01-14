open Belt
open Phaser
open Utils
open GameObject

let scene = Scene.create "board"

type states = EMPTY | PLACED | NEW | LOCKED


type board_entry =
  { value: int
  ; zone: Zone.zone option
  ; graphics: Graphics.graphics option
  ; state: states
  ; sprite: Sprite.sprite option }

type player = {score: int; id: string}

let grid_w = 6

let grid_h = 6

let board_container: Container.container option ref = ref None

let config : scene_config ref = init_config () |. ref

let create_board_entry ?(value = 0) ?(zone = None) ?(graphics = None)
    ?(sprite = None) ?(state = EMPTY) () =
  {value; zone; graphics; state; sprite}


let board  =
  get_n_m_board grid_h grid_w 0
  |. map_matrix (fun _ -> create_board_entry ())

type card = { is_done: bool; container: Container.container option }

let cards = 
  Array.make 5 {is_done = false; container = None}

let set_board x y value = set_unsafe board x y value

let get_board x y = get_unsafe board x y

let scores: (string * Text.text) array option ref = ref None

let has_match pattern =
  let num_stones =
    Array.concatMany pattern
    |. Array.reduce 0. (fun acc slot -> if slot = 1. then acc +. 1. else acc)
  in
  let board_matrix = Utils.map_matrix board (fun entry -> float_of_int entry.value) in
  conv board_matrix pattern
  |. Array.concatMany
  |. Array.some (fun e -> e = num_stones)

let matches_any_rot pattern =
  Deck_generator.get_all_rots pattern
  |. List.map has_match
  |. List.some (fun isMatch -> Js.log isMatch; isMatch)


let matches_any_pattern () =
  Array.mapWithIndex !config.state.hand (fun i pattern ->
      (i, has_match pattern) )
  |. Array.keep (fun (_, hasMatch) -> hasMatch)

let get_game_dim () =
  Scene.sysGet scene |. Scene.canvasGet
  |. fun c -> (Scene.widthGet c, Scene.heightGet c)

let get_board_dim () = 
  let w, _ = get_game_dim () in 
  w *. 0.8, w *. 0.8

let modify_slot x y =
  let entry = get_board x y in
  match entry.state with
  | EMPTY ->
      1, NEW
  | PLACED ->
      0, EMPTY
  | NEW -> 1, NEW
  | LOCKED -> 0, LOCKED

let draw_board ?(x_offset = 0.0) ?(y_offset = 0.0) w =
  let object_factor = Scene.addGet scene in
  let board_container_ = container object_factor in
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
      add_container board_container_ (`Graphics slot) ;
      add_container board_container_ (`Zone hit_zone) ;
      set_board j i
        {(get_board j i) with zone= Some hit_zone; graphics= Some slot}
    done
  done ;
  Container.set_position board_container_ x_offset y_offset;
  board_container := Some board_container_

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

let restrict_board () =
  if Array.length !config.state.players < 4 then (
    grid_h - 1 |. lock_row ;
    grid_w - 1 |. lock_col ) ;
  if Array.length !config.state.players < 3 then ( lock_row 0 ; lock_col 0 )

let create_scores () =
  let object_factory = Scene.addGet scene in
  let style = Text.style ~fill:"#000" ~fontSize:"16px" in
  let _scores = 
    Array.copy !config.state.players
    |. Array.mapWithIndex (fun idx player ->
          let text = "Player " ^ string_of_int (idx + 1) ^
            if player.id = !config.state.id then " (me)" else "" in
          player.id, text_with_style object_factory 16 (16 + (16 * idx)) text style ) in
  scores := Some _scores

let create_sprite factory key x y w h = 
  let s = sprite factory x y key in
  Sprite.displayWidthSet s w;
  Sprite.displayHeightSet s h;
  s

let draw_card scene pattern x y w h = 
  let object_factory = Scene.addGet scene in
  let card_container = container object_factory in
  let card_w_f = 3.0 in
  let card_h_f = 3.0 in
  let s_width = w /. card_w_f in
  let s_height = h /. card_h_f in
  let {width = m_width; height = m_height} = Utils.scale_marble_size s_width s_height 30.0 in
  for i = 0 to int_of_float card_h_f - 1 do
    for j = 0 to int_of_float card_w_f - 1 do
      let slot = graphics object_factory in
      let apply f = slot |. f in
      let s_x = float_of_int j *. s_width in
      let s_y = float_of_int i *. s_height in
      apply Graphics.lineStyle 5.0 (parse_int "E1E2E1" 16) 1.0 ;
      apply Graphics.fillStyle (parse_int "bbdefb" 16) 1.0 ;
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
      add_container card_container (`Graphics slot) ;
      if get_unsafe pattern j i = 1.0 then (
        let marble_sprite = create_sprite object_factory "marble" 
          (s_x +. s_width *. 0.5) (s_y +. s_height *. 0.5) m_width m_height in 
        add_container card_container (`Sprite marble_sprite)  
        )
    done
  done ;
  Container.set_position card_container x y;
  card_container 

let get_card idx = 
  Array.getExn cards idx 

let draw_done_overlay idx = 
  let cur_card = get_card idx in
  match cur_card.container with 
  | None -> Js.log "no container"
  | Some container ->
    if cur_card.is_done = false then (
      let object_factory = Scene.addGet scene in
      let overlay = graphics object_factory in
      let width = Container.displayWidthGet container in 
      let height = Container.displayHeightGet container in
      (* draw overlay *)
      Graphics.fillStyle overlay (parse_int "757575" 16) 0.5;
      Graphics.fillRect overlay 0.0 0.0  width height;
      (* add check sprite *)
      let done_sprite = create_sprite object_factory "check" (width *. 0.5) (height *. 0.5) (width *. 0.3) (width *. 0.3) in
      Sprite.set_origin done_sprite 0.5 0.5;
      add_container container (`Graphics overlay);
      add_container container (`Sprite done_sprite);
    )

let draw_hand w h = 
  let padding = 20. in
  let width = w /. 5. -. padding in
  let y = 0.8 *. h in 
  let draw_card idx pattern =
    let idx_f = float_of_int idx in
    let x = width *. idx_f +. padding *. idx_f in
    let container = Some (draw_card scene pattern x y width width) in
    Array.setExn cards idx {is_done = false; container} in
  Array.forEachWithIndex !config.state.hand draw_card

let isTurn ?(id = !config.state.id ) () = id = !config.state.last_move.next_player

let finish_turn x y = 
  for_each_matrix_with_index board (fun i j slot -> 
    if slot.state = NEW then set_board i j { slot with state = PLACED };
  );
  if isTurn () then !config.send_move x y

let destroy_sprite_safe sprite = 
  match sprite with 
    | Some sprite -> Sprite.destroy sprite
    | _ -> Js.log "nothing to destroy"

let draw_marble_in_zone zone = 
  let object_factory = Scene.addGet scene in
  let board_w, board_h = get_board_dim () in 
  let zone = Option.getExn zone in
  let marble_x = Zone.xGet zone in
  let marble_y = Zone.yGet zone in
  let {width = marble_w; height = marble_h} = scale_marble_size board_w board_h 30.0 in 
  let sprite_object = create_sprite object_factory "marble" marble_x marble_y marble_w marble_h in
  Option.getExn !board_container |. add_container (`Sprite sprite_object);
  sprite_object

let find_match () = 
  let matches = matches_any_pattern () in 
    if Array.length matches > 0 then (
      let idx, _ = Array.getExn matches 0 in
      idx
    )
    else -1
 
let handle_slot_clicked x y = 
  let {zone; state; sprite } = get_board x y in
  if state <> LOCKED && state <> NEW then  
    let new_value, new_state = modify_slot x y in
    let new_sprite = 
      if ( new_state = EMPTY) then (destroy_sprite_safe sprite; None)
      else Some (draw_marble_in_zone zone) in
    finish_turn (float_of_int x) (float_of_int y);
    set_board x y { (get_board x y) with state = new_state; value = new_value; sprite = new_sprite};  
    let match_idx = find_match () in
    if match_idx <> -1 then draw_done_overlay match_idx
    
let add_board_events () =
  let add_click_callback i j slot =
    match slot.zone with
    | Some zone -> Zone.on zone "pointerdown" 
        (fun _ -> if isTurn () then handle_slot_clicked i j)
    | _ -> ()
  in
  for_each_matrix_with_index board add_click_callback

let create () =
  let w, h = get_game_dim () in
  let width = w *. 0.8 in
  draw_board ~x_offset:(0.1 *. w) ~y_offset:(0.15 *. h) width;
  let _ = create_scores () in
  restrict_board ();
  add_board_events ();
  draw_hand w h


let handle_move move =  
  let { State.x; State.y; _ } = move in
  if x > 0 && y > 0 && isTurn () = false 
    then handle_slot_clicked x y

let update_scores () = 
  match !scores with 
  | Some scores -> Array.forEach scores (fun (id, text) -> 
      Text.set_font_style text (if isTurn ~id:id () then "bold" else "")
      )
  | None -> ()

let init _config =
  config := _config ;
  let _ = !config.subscribe State.move_event (fun state -> 
    handle_move state.last_move;
    config := { !config with state }) in
  let _ = !config.subscribe State.winner_event (fun state -> 
    Js.log "winner";
    config := { !config with state };
    let manager =  Scene.gameGet scene |. sceneGet in
    SceneManager.stop manager "board";
    SceneManager.start manager "end" !config;
  ) in
  ()

let update () = 
  update_scores ()

let state = State.init ()

let listeners = Map.String.empty

let () =
  Scene.initSet scene init;
  Scene.createSet scene create;
  Scene.preloadSet scene preload;
  Scene.updateSet scene update;
