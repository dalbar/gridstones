// Generated by BUCKLESCRIPT VERSION 4.0.14, PLEASE EDIT WITH CARE

import * as Curry from "../../node_modules/bs-platform/lib/es6/curry.js";
import * as State from "./state.bs.js";
import * as Utils from "./utils.bs.js";
import * as Phaser from "phaser";
import * as Caml_option from "../../node_modules/bs-platform/lib/es6/caml_option.js";

var scene = new Phaser.Scene("menu");

var config = /* record */[/* contents */Utils.init_config(undefined, undefined, undefined, undefined, undefined, undefined, /* () */0)];

var start_button = /* record */[/* contents */undefined];

var player_count = /* record */[/* contents */undefined];

function start_game(param) {
  if (param[/* phase */3] === "start" && param[/* id */2] !== "") {
    var m = scene.game.scene;
    m.stop("menu");
    m.start("board", config[0]);
    return /* () */0;
  } else {
    return 0;
  }
}

function create(param) {
  var object_factory = scene.add;
  var canvas = scene.sys.canvas;
  var width = canvas.width;
  var height = canvas.height;
  var style_start = {
    fill: "0",
    fontSize: "32px"
  };
  var new_button = object_factory.text(width * 0.5 | 0, height * 0.5 | 0, "Start", style_start);
  new_button.setInteractive();
  new_button.on("pointerdown", config[0][/* send_start */5]);
  new_button.setOrigin(0.5, 0.5);
  start_button[0] = Caml_option.some(new_button);
  var style_count = {
    fill: "0",
    fontSize: "16px"
  };
  var new_player_count = object_factory.text(width * 0.5 | 0, height * 0.5 - 32 - 10 | 0, "", style_count);
  new_player_count.setOrigin(0.5, 0.5);
  player_count[0] = Caml_option.some(new_player_count);
  return /* () */0;
}

function init(_config) {
  var update_state = function (state) {
    var init = config[0];
    config[0] = /* record */[
      /* state */state,
      /* subscribe */init[/* subscribe */1],
      /* send_move */init[/* send_move */2],
      /* send_winner */init[/* send_winner */3],
      /* handle_register */init[/* handle_register */4],
      /* send_start */init[/* send_start */5]
    ];
    return /* () */0;
  };
  config[0] = _config;
  if (config[0][/* state */0][/* id */2] === "") {
    Curry._1(config[0][/* handle_register */4], /* () */0);
  }
  Curry._2(config[0][/* subscribe */1], State.players_event, update_state);
  Curry._2(config[0][/* subscribe */1], State.id_event, update_state);
  Curry._2(config[0][/* subscribe */1], State.hand_event, update_state);
  Curry._2(config[0][/* subscribe */1], State.phase_event, start_game);
  return /* () */0;
}

function update(param) {
  var match = player_count[0];
  if (match !== undefined) {
    Caml_option.valFromOption(match).text = "Number of players: " + String(config[0][/* state */0][/* players */1].length);
    return /* () */0;
  } else {
    return /* () */0;
  }
}

scene.create = create;

scene.init = init;

scene.update = update;

export {
  scene ,
  config ,
  start_button ,
  player_count ,
  start_game ,
  create ,
  init ,
  update ,
  
}
/* scene Not a pure module */