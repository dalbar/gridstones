open Belt

type move = {x: int; y: int; next_player: string}

exception JSON_EXEP of string

let decode_json json =
  let t = Js.Json.classify json in
  match t with
  | JSONFalse -> `Boolean false
  | JSONTrue -> `Boolean true
  | JSONNull -> `Null Js.null
  | JSONString str -> `String str
  | JSONNumber number -> `Number number
  | JSONObject obj -> `Object obj
  | JSONArray arr -> `Array arr

let decode_json_string json =
  match decode_json json with
  | `String str -> str
  | _ -> raise (JSON_EXEP "not a string")

let decode_json_number json =
  match decode_json json with
  | `Number number -> number
  | _ -> raise (JSON_EXEP "not a number")

let decode_json_number_array json =
  match decode_json json with
  | `Array arr -> arr
  | _ -> raise (JSON_EXEP "not an array")

let decode_json_matrix_2d json =
  decode_json_number_array json
  |. Array.map (fun row ->
         decode_json_number_array row |. Array.map decode_json_number )

let decode_json_matrix_3d json =
  decode_json_number_array json
  |. Array.map (fun d2 -> decode_json_matrix_2d d2)

let parse_int_from_dict dict key =
  Js.Dict.unsafeGet dict key |. Js.Json.decodeNumber |. Belt.Option.getExn
  |. int_of_float

let parse_string_from_dict dict key =
  Js.Dict.unsafeGet dict key |. Js.Json.decodeString |. Belt.Option.getExn

let parse_move_object dict =
  let x = parse_int_from_dict dict "x" in
  let y = parse_int_from_dict dict "y" in
  let next_player = parse_string_from_dict dict "nextPlayer" in
  {x; y; next_player}

type player = {id: string; score: int}

let parse_player_object dict =
  let score = parse_int_from_dict dict "score" in
  let id = parse_string_from_dict dict "id" in
  {id; score}

type pattern = float array array

type state =
  { last_move: move
  ; players: player array
  ; id: string
  ; phase: string
  ; hand: pattern array
  ; winner: string }

let init () =
  { last_move= {x= -1; y= -1; next_player= ""}
  ; players= [||]
  ; id= ""
  ; phase= ""
  ; hand= [||]
  ; winner= "" }

let move_event = "move"

let players_event = "move"

let id_event = "id"

let hand_event = "hand"

let phase_event = "phase"

let winner_event = "winner"

type action =
  | MOVE of move
  | PLAYERS of player array
  | ID of string
  | HAND of pattern array
  | PHASE of string
  | WINNER of string
[@@bs.deriving accessors]

let initMap () = Belt_MapString.empty

let notify listeners key state =
  if Belt_MapString.has listeners key then
    Belt_MapString.getExn listeners key |. Array.forEach (fun fn -> fn state)

let update_state state action =
  match action with
  | MOVE last_move -> {state with last_move}
  | PLAYERS players -> {state with players}
  | ID id -> {state with id}
  | HAND hand -> {state with hand}
  | WINNER winner -> {state with winner}
  | PHASE phase -> {state with phase}

let dispatch state listeners key action =
  let new_state = update_state state action in
  notify listeners key new_state ;
  new_state

let subscribe listeners event fn =
  let new_list =
    try
      let cur_listeners = Belt_MapString.getExn listeners event in
      Array.make 1 fn |> Array.concat cur_listeners
    with _ -> Array.make 1 fn
  in
  let newIndex = Array.length new_list in
  (Belt_MapString.set listeners event new_list, newIndex)

let unsubscribe listeners event idx =
  try
    Belt_MapString.getExn listeners event
    |. Array.keepWithIndex (fun _ i -> i <> idx)
    |> Belt_MapString.set listeners event
  with _ -> listeners
