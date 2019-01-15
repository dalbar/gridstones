// Generated by BUCKLESCRIPT VERSION 4.0.14, PLEASE EDIT WITH CARE

import * as Phaser from "phaser";
import * as Caml_option from "../../node_modules/bs-platform/lib/es6/caml_option.js";

var scene = new Phaser.Scene("end");

var config = /* record */[/* contents */undefined];

var back_button = /* record */[/* contents */undefined];

var end_text = /* record */[/* contents */undefined];

function handle_back(param) {
  var manager = scene.game.scene;
  manager.stop("end");
  manager.start("menu", config[0]);
  return /* () */0;
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
  var new_button = object_factory.text(width * 0.5 | 0, height * 0.5 | 0, "Back", style_start);
  new_button.setInteractive();
  new_button.on("pointerdown", handle_back);
  new_button.setOrigin(0.5, 0.5);
  back_button[0] = Caml_option.some(new_button);
  var style_count = {
    fill: "0",
    fontSize: "16px"
  };
  var _end_text = object_factory.text(width * 0.5 | 0, height * 0.5 - 32 - 10 | 0, "", style_count);
  _end_text.setOrigin(0.5, 0.5);
  var match = config[0];
  if (match !== undefined) {
    var config$1 = match;
    _end_text.text = config$1[/* state */0][/* winner */5] === config$1[/* state */0][/* id */2] ? "You won the game!" : "You lost the game!";
    end_text[0] = Caml_option.some(_end_text);
    return /* () */0;
  } else {
    console.log("no config received");
    return /* () */0;
  }
}

function init(_config) {
  config[0] = _config;
  return /* () */0;
}

scene.create = create;

scene.init = init;

export {
  scene ,
  config ,
  back_button ,
  end_text ,
  handle_back ,
  create ,
  init ,
  
}
/* scene Not a pure module */
