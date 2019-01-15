open Phaser
open GameObject

let scene = Scene.create "menu"

let config : Utils.scene_config ref = Utils.init_config () |. ref

let start_button : Text.text option ref = ref None

let player_count : Text.text option ref = ref None

let subs = Belt.MutableStack.make ()

let unsubscribe () = 
  let rec loop () = 
    match Belt.MutableStack.pop subs with
    | Some (event, idx) -> !config.unsubscribe event idx; loop ()
    | None -> () in 
  loop()


let start_game {State.phase; State.id; _} =
  Js.log "running";
  if phase = "start" then
    if id <> "" then (
      Scene.gameGet scene |. sceneGet
      |. fun m ->
      SceneManager.stop m "menu";
      SceneManager.stop m "end";
      SceneManager.start m "board" !config )
    else
      match !start_button with
      | Some start_button ->
          Text.textSet start_button "Game has started. Try later!"
      | None -> ()

let create () =
  let object_factory = Scene.addGet scene in
  let canvas = Scene.sysGet scene |. Scene.canvasGet in
  let width = Scene.widthGet canvas in
  let height = Scene.heightGet canvas in
  let style_start = Text.style ~fill:"0" ~fontSize:"32px" in
  let new_button =
    text_with_style object_factory
      (int_of_float (width *. 0.5))
      (int_of_float (height *. 0.5))
      "Start" style_start
  in
  set_interactive_text new_button ;
  on_text new_button "pointerdown" !config.send_start ;
  Text.set_origin new_button 0.5 0.5 ;
  start_button := Some new_button ;
  let style_count = Text.style ~fill:"0" ~fontSize:"16px" in
  let new_player_count =
    text_with_style object_factory
      (int_of_float (width *. 0.5))
      (int_of_float ((height *. 0.5) -. 32. -. 10.))
      "" style_count
  in
  Text.set_origin new_player_count 0.5 0.5 ;
  player_count := Some new_player_count

let init _config =
  let push_sub t  = Belt.MutableStack.push subs t in
  let update_state state = config := {!config with state} in
  config := _config ;
  if !config.state.id = "" then !config.handle_register () ;
  !config.subscribe State.players_event update_state |. push_sub;
  !config.subscribe State.id_event update_state |. push_sub;
  !config.subscribe State.hand_event update_state |. push_sub; 
  !config.subscribe State.phase_event start_game |. push_sub

let update () =
  match !player_count with
  | Some player_count ->
      if !config.state.id <> "" then
        Text.textSet player_count
          ( "Number of players:" ^ " "
          ^ string_of_int (Array.length !config.state.players) )
  | None -> ()

let () =
  Scene.createSet scene create ;
  Scene.initSet scene init ;
  Scene.updateSet scene update
