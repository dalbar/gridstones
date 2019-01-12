module GameObject = struct
  module Zone = struct
    type zone

    external zone : unit -> zone = "Zone" [@@bs.new] [@@bs.module]

    external on : zone -> string -> (unit -> unit) -> unit = "on" [@@bs.send]
  end

  type gameObjectFactory = {setInteractive: unit -> unit}

  module Sprite = struct
    type sprite = {displayWidth: float; displayHeight: float}

    external create : unit -> sprite = "Sprite" [@@bs.new] [@@bs.module]

    external destroy : sprite -> unit = "destroy" [@@bs.send]
  end

  module Graphics = struct
    type graphics

    external graphics : unit -> graphics = "Graphics" [@@bs.new] [@@bs.module]

    external lineStyle :
      graphics -> float -> int -> float -> unit
      = "lineStyle"
      [@@bs.send]

    external fillStyle : graphics -> int -> float -> unit = "fillStyle"
      [@@bs.send]

    external moveTo : graphics -> float -> float -> unit = "moveTo" [@@bs.send]

    external lineTo : graphics -> float -> float -> unit = "lineTo" [@@bs.send]

    external strokePath : graphics -> unit = "strokePath" [@@bs.send]

    external beginPath : graphics -> unit = "beginPath" [@@bs.send]

    external fillRect :
      graphics -> float -> float -> float -> float -> unit
      = "fillRect"
      [@@bs.send]
  end

  module Container = struct
    type container

    external container : unit -> container = "Container"
      [@@bs.new] [@@bs.module]

    external set_position : container -> float -> float -> unit = "setPosition"
      [@@bs.send]
  end

  open Graphics
  open Container
  open Zone

  external add_container :
    container -> ([`Zone of zone | `Graphics of graphics][@bs.unwrap]) -> unit
    = "add"
    [@@bs.send]

  external zone :
    gameObjectFactory -> float -> float -> float -> float -> zone
    = "zone"
    [@@bs.send]

  external graphics : gameObjectFactory -> graphics = "graphics" [@@bs.send]

  external container : gameObjectFactory -> container = "container" [@@bs.send]

  external set_interactive_zone : zone -> unit = "setInteractive" [@@bs.send]
end

module LoaderPlugin = struct
  type loader_plugin

  external create_loader_plugin : unit -> loader_plugin = "Loader.LoaderPlugin"
    [@@bs.module] [@@bs.new]

  external image : loader_plugin -> string -> string -> unit = "image"
    [@@bs.send]
end

module Scene = struct
  open GameObject

  type canvas = {width: float; height: float} [@@bs.deriving abstract]

  type sys = {canvas: canvas} [@@bs.deriving abstract]

  type container =
    {setInteractive: unit -> unit; setPosition: float -> float -> unit}
  [@@bs.deriving abstract]

  type scene =
    { mutable update: unit -> unit
    ; mutable preload: unit -> unit
    ; mutable create: unit -> unit
    ; mutable init: unit -> unit
    ; sys: sys
    ; add: gameObjectFactory
    ; load: LoaderPlugin.loader_plugin }
  [@@bs.deriving abstract]

  type config = {key: string} [@@bs.deriving abstract]

  external create : config -> scene = "Scene" [@@bs.new] [@@bs.module "phaser"]
end
