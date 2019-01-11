type position = float * float

type style_config = int * float

type pos_config = float * float * float * float

module GameObject = struct
  module Zone = struct
    type zone
    external zone: unit -> zone = "Zone" [@@bs.new] [@@bs.module]
  end

  type gameObjectFactory = {setInteractive: unit -> unit}

  module Graphics = struct
    type graphics
    external graphics : unit -> graphics = "Graphics" [@@bs.new] [@@bs.module]


    external lineStyle : graphics -> style_config -> unit = "lineStyle"
      [@@bs.send]

    external fillStyle : graphics -> style_config -> unit = "fillStyllE"
      [@@bs.send]

    external moveTo : graphics -> position -> unit = "moveTo" [@@bs.send]

    external lineTo : graphics -> position -> unit = "lineTo" [@@bs.send]

    external strokePath : graphics -> unit = "strokePath" [@@bs.send]

    external beginPath : graphics -> unit = "beginPath" [@@bs.send]

    external fillRect : graphics -> pos_config -> unit = "fillRect" [@@bs.send]
  end

  module Container = struct
    type container
    external container : unit -> container = "Container" [@@bs.new] [@@bs.module]
    external set_position: container -> position -> unit = "setPosition" [@@bs.send]
  end

  open Graphics
  open Container
  open Zone


  external add_container : container -> ([`Zone of zone | `Graphics of graphics] [@bs.unwrap]) -> unit = "add" [@@bs.send]

  external zone : gameObjectFactory -> pos_config -> zone = "zone" [@@bs.send]

  external graphics : gameObjectFactory -> graphics = "graphics" [@@bs.send]

  external container : gameObjectFactory -> container = "container" [@@bs.send]

  external set_interactive_zone : zone -> unit = "setInteractive" [@@bs.send]
end

module Scene = struct
  open GameObject

  type canvas = {width: float; height: float}

  type sys = {canvas: canvas}

  type container =
    {setInteractive: unit -> unit; setPosition: float -> float -> unit}
  [@@bs.deriving abstract]

  type scene =
    { mutable update: unit -> unit
    ; mutable preload: unit -> unit
    ; mutable create: unit -> unit
    ; mutable init: unit -> unit
    ; sys: sys
    ; add: gameObjectFactory }
  [@@bs.deriving abstract]

  type config = {key: string} [@@bs.deriving abstract]

  external create : config -> scene = "Scene" [@@bs.new] [@@bs.module "phaser"]
end
