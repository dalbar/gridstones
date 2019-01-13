module WebSocket = struct
  type t

  type event = string Js.Dict.t

  external create : string -> t = "WebSocket" [@@bs.new]

  external add_listener :
    t -> string -> (event -> unit) -> unit
    = "addEventListener"
    [@@bs.send]

  external send : t -> string -> unit = "send" [@@bs.send]
end
