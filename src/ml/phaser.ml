type position = float * float

type style_config = int * float

type pos_config = float * float * float * float



module GameObject = struct

  type zone = {x: int; y: int}

  type gameObjectFactory = {setInteractive: unit -> unit }

  module Graphics = struct
  type graphics = {x: float; y: float}

  external lineStyle : graphics -> style_config -> unit = "lineStyle"
    [@@bs.send]

  external fillStyle : graphics -> style_config -> unit = "fillStyllE"
    [@@bs.send]

  external moveTo : graphics -> position -> unit = "moveTo" [@@bs.send]

  external lineTo : graphics -> position -> unit = "lineTo" [@@bs.send]

  external strokePath : graphics -> position -> unit = "strokePath" [@@bs.send]

  external beginPath : graphics -> unit = "beginPath" [@@bs.send]
end

module Container = struct 
  type container = {setPosition: position -> unit}
end
    
  open Graphics
  open Container

  type gameObject =
    | Container of container
    | Zone of zone
    | Graphics of graphics


  external add: gameObject -> gameObject -> unit = "add" [@@bs.send]

  external zone : gameObjectFactory -> pos_config -> zone = "zone" [@@bs.send]

  external graphics : gameObjectFactory -> graphics = "graphics" [@@bs.send]

  external container : gameObjectFactory -> container = "container" [@@bs.send]

  external setInteractive : gameObject -> unit = "setInteractive" [@@bs.send]
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
