module GameObject = struct
  module Zone = struct
    type zone = { x: float; y: float } [@@bs.deriving abstract]

    external zone : unit -> zone = "Zone" [@@bs.new] [@@bs.module]

    external on : zone -> string -> (unit -> unit) -> unit = "on" [@@bs.send]
  end

  type gameObjectFactory = {setInteractive: unit -> unit}

  module Text = struct
    type text = {mutable text: string} [@@bs.deriving abstract]

    type style = {fill: string; fontSize: string} [@@bs.deriving abstract]

    external create : unit -> text = "Phaser.GameObjects.Text" [@@bs.new]

    external set_origin : text -> float -> float -> unit = "setOrigin"
      [@@bs.send]
    
    external set_font_style: text -> string -> unit = "setFontStyle" [@@bs.send]
  end

  module Sprite = struct
    type sprite = {mutable displayWidth: float; mutable displayHeight: float} [@@bs.deriving abstract]

    external create : unit -> sprite = "Sprite" [@@bs.new] [@@bs.module]

    external destroy : sprite -> unit = "destroy" [@@bs.send]

    external set_origin : sprite -> float -> float -> unit = "setOrigin"
      [@@bs.send]
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
    type container = { displayWidth: float; displayHeight: float } [@@bs.deriving abstract]

    external container : unit -> container = "Container"
      [@@bs.new] [@@bs.module]

    external set_position : container -> float -> float -> unit = "setPosition"
      [@@bs.send]
  end

  open Graphics
  open Container
  open Zone
  open Text

  external add_container :
    container -> ([`Zone of zone | `Graphics of graphics | `Sprite of Sprite.sprite ][@bs.unwrap]) -> unit
    = "add"
    [@@bs.send]

  external set_interactive_text : text -> unit = "setInteractive" [@@bs.send]

  external on_text : text -> string -> (unit -> unit) -> unit = "on"
    [@@bs.send]

  external zone :
    gameObjectFactory -> float -> float -> float -> float -> zone
    = "zone"
    [@@bs.send]

  external graphics : gameObjectFactory -> graphics = "graphics" [@@bs.send]

  external container : gameObjectFactory -> container = "container" [@@bs.send]

  external sprite : gameObjectFactory -> float -> float -> string -> Sprite.sprite = "sprite" [@@bs.send]

  external text_with_style :
    gameObjectFactory -> int -> int -> string -> Text.style -> text
    = "text"
    [@@bs.send]

  external set_interactive_zone : zone -> unit = "setInteractive" [@@bs.send]
end

module LoaderPlugin = struct
  type loader_plugin

  external create_loader_plugin : unit -> loader_plugin = "Loader.LoaderPlugin"
    [@@bs.module] [@@bs.new]

  external image : loader_plugin -> string -> string -> unit = "image"
    [@@bs.send]
end

module SceneManager = struct
  type t

  external create : unit -> t = "Scenes.SceneManager" [@@bs.module] [@@bs.new]

  external start : t -> string -> 'a -> unit = "start" [@@bs.send]

  external stop : t -> string -> unit = "stop" [@@bs.send]

  external add : t -> string -> 'a -> unit = "add" [@@bs.send]
end

type game = {scene: SceneManager.t} [@@bs.deriving abstract]

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
    ; mutable init: Utils.scene_config -> unit
    ; sys: sys
    ; game: game
    ; add: gameObjectFactory
    ; load: LoaderPlugin.loader_plugin }
  [@@bs.deriving abstract]

  external create : string -> scene = "Scene" [@@bs.new] [@@bs.module "phaser"]
end

module Game = struct
  type config =
    { width: int
    ; height: int
    ; type_: string [@bs.as "type"]
    ; backgroundColor: string
    ; scene: Scene.scene list }
  [@@bs.deriving abstract]

  external create : config -> game = "Game" [@@bs.new] [@@bs.module "phaser"]
end
