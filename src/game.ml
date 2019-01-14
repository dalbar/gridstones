open Sockets
open Phaser

let type_ : string = [%raw "Phaser.AUTO"]

let game_config =
  Game.config ~width:600 ~height:800 ~type_ ~backgroundColor:"#f3cca3"
    ~scene:[]

let game = Game.create game_config

let address = "ws://127.0.0.1:8081"

let ws = WebSocket.create address

let game_state = State.init () |. ref

let listeners = ref Belt.Map.String.empty

let set_game_state new_state = game_state := new_state

let dispatch_game_state key action =
  game_state := State.dispatch !game_state !listeners key action

let handle_event event =
  let data =
    Js.Dict.unsafeGet event "data"
    |. Js.Json.parseExn |. Js.Json.decodeObject |. Belt.Option.getExn
  in
  let get_value key = Js.Dict.unsafeGet data key in
  let type_ =
    Js.Dict.unsafeGet data "type" |. Js.Json.decodeString |. Belt.Option.getExn
  in
  match type_ with
  | "ID" ->
      let id = get_value "id" |. State.decode_json_string in
      dispatch_game_state State.id_event (State.ID id)
  | "PLAYERS" ->
      let players =
        get_value "players" |. Js.Json.decodeArray |. Belt.Option.getExn
        |. Belt.Array.map (fun player ->
               Js.Json.decodeObject player
               |. Belt.Option.getExn |. State.parse_player_object )
      in
      dispatch_game_state State.players_event (State.PLAYERS players)
  | "PHASE" ->
      let phase = get_value "phase" |. State.decode_json_string in
      dispatch_game_state State.phase_event (State.PHASE phase)
  | "MOVE" ->
      let move =
        get_value "move" |. State.decode_json_string |. Js.Json.parseExn
        |. Js.Json.decodeObject |. Belt.Option.getExn
        |. State.parse_move_object
      in
      dispatch_game_state State.move_event (State.MOVE move)
  | "HAND" ->
      let hand =
        get_value "hand" |. State.decode_json_string |. Js.Json.parseExn
        |. State.decode_json_matrix_3d
      in
      dispatch_game_state State.hand_event (State.HAND hand)
  | "WINNER" ->
      let winner = get_value "id" |. State.decode_json_string in
      dispatch_game_state State.winner_event (State.WINNER winner)
  | _ -> ()

let send_js_dict dict =
  Js.Json.object_ dict |. Js.Json.stringify |> WebSocket.send ws

let handle_register () =
  let register_msg = Js.Dict.empty () in
  Js.Dict.set register_msg "type" (Js.Json.string "REGISTER") ;
  send_js_dict register_msg

let send_start () =
  let start_msg = Js.Dict.empty () in
  Js.Dict.set start_msg "type" (Js.Json.string "PHASE") ;
  Js.Dict.set start_msg "phase" (Js.Json.string "start") ;
  send_js_dict start_msg

let send_move x y =
  let move_msg = Js.Dict.empty () in
  let move_dict = Js.Dict.empty () in
  Js.Dict.set move_dict "x" (Js.Json.number x) ;
  Js.Dict.set move_dict "y" (Js.Json.number y) ;
  Js.Dict.set move_msg "type" (Js.Json.string "MOVE") ;
  Js.Dict.set move_msg "move"
    (Js.Json.object_ move_dict |. Js.Json.stringify |. Js.Json.string) ;
  send_js_dict move_msg

let send_winner id =
  let winner_msg = Js.Dict.empty () in
  Js.Dict.set winner_msg "type" (Js.Json.string "WINNER") ;
  Js.Dict.set winner_msg "id" (Js.Json.string id) ;
  send_js_dict winner_msg

let subscribe _event fn =
  let _listeners, idx =
    State.subscribe !listeners _event (fun state -> fn state)
  in
  listeners := _listeners ;
  idx

let scene_config =
  { Utils.state= !game_state
  ; subscribe
  ; send_move
  ; send_winner
  ; handle_register
  ; send_start }

let handle_open () =
  let manager = sceneGet game in
  SceneManager.add manager "menu" Menu.scene ;
  SceneManager.add manager "board" Board.scene ;
  SceneManager.add manager "end" End_screen.scene ;
  SceneManager.start manager "menu" scene_config

let () =
  WebSocket.add_listener ws "open" (fun _ -> handle_open ()) ;
  WebSocket.add_listener ws "message" (fun event -> handle_event event)
