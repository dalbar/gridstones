open Phaser
open GameObject

open State

let scene = Scene.create "end"

let config : Utils.scene_config option ref = ref None

let back_button : Text.text option ref = ref None

let end_text : Text.text option ref = ref None

let handle_back () = 
  let manager = Scene.gameGet scene |. sceneGet in
  SceneManager.stop manager "end";
  SceneManager.start manager "menu" !config

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
      "Back" style_start
  in
  set_interactive_text new_button ;
  on_text new_button "pointerdown" handle_back;
  Text.set_origin new_button 0.5 0.5 ;
  back_button := Some new_button ;
  let style_count = Text.style ~fill:"0" ~fontSize:"16px" in
  
  let _end_text =
    text_with_style object_factory
      (int_of_float (width *. 0.5))
      (int_of_float ((height *. 0.5) -. 32. -. 10.))
      "" style_count
  in
  Text.set_origin _end_text 0.5 0.5 ;
  match !config with 
  | Some config -> 
      Text.textSet _end_text (if config.state.winner = config.state.id then "You won the game!" else "You lost the game!");
      end_text := Some _end_text
  | None -> Js.log ("no config received")

let init _config =
  config := Some _config

let () =
  Scene.createSet scene create ;
  Scene.initSet scene init