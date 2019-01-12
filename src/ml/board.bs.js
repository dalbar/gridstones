// Generated by BUCKLESCRIPT VERSION 4.0.14, PLEASE EDIT WITH CARE

import * as Block from "../../node_modules/bs-platform/lib/es6/block.js";
import * as Curry from "../../node_modules/bs-platform/lib/es6/curry.js";
import * as State from "./state.bs.js";
import * as Utils from "./utils.bs.js";
import * as Phaser from "phaser";
import * as Belt_List from "../../node_modules/bs-platform/lib/es6/belt_List.js";
import * as Belt_Array from "../../node_modules/bs-platform/lib/es6/belt_Array.js";
import * as Caml_option from "../../node_modules/bs-platform/lib/es6/caml_option.js";
import * as Belt_MapString from "../../node_modules/bs-platform/lib/es6/belt_MapString.js";
import * as Deck_generator from "./deck_generator.bs.js";

var players = Belt_List.make(0, /* record */[
      /* score */0,
      /* id */""
    ]);

var config = /* record */[/* contents : record */[
    /* players */players,
    /* id */"",
    /* subscribe */(function (param, param$1) {
        return -1;
      }),
    /* sendMove */(function (param, param$1) {
        return /* () */0;
      }),
    /* sendWinner */(function (param) {
        return /* () */0;
      }),
    /* hand */0
  ]];

function init_marble(param) {
  return /* record */[
          /* sprite */undefined,
          /* state : EMPTY */0
        ];
}

function create_board_entry($staropt$star, $staropt$star$1, $staropt$star$2, $staropt$star$3, $staropt$star$4, param) {
  var value = $staropt$star !== undefined ? $staropt$star : 0;
  var zone = $staropt$star$1 !== undefined ? Caml_option.valFromOption($staropt$star$1) : undefined;
  var graphics = $staropt$star$2 !== undefined ? Caml_option.valFromOption($staropt$star$2) : undefined;
  var sprite = $staropt$star$3 !== undefined ? Caml_option.valFromOption($staropt$star$3) : undefined;
  var state = $staropt$star$4 !== undefined ? $staropt$star$4 : /* EMPTY */0;
  return /* record */[
          /* value */value,
          /* zone */zone,
          /* graphics */graphics,
          /* state */state,
          /* sprite */sprite
        ];
}

function has_match(board_state, pattern) {
  var num_stones = Belt_Array.reduce(Belt_Array.concatMany(pattern), 0, (function (acc, slot) {
          if (slot === 1) {
            return acc + 1 | 0;
          } else {
            return acc;
          }
        }));
  return Belt_Array.some(Belt_Array.concatMany(Utils.conv(board_state, pattern)), (function (e) {
                return e === num_stones;
              }));
}

function matches_any_rot(board_state, pattern) {
  var matches_cur_board = function (p) {
    return has_match(board_state, p);
  };
  return Belt_List.some(Belt_List.map(Deck_generator.get_all_rots(pattern), matches_cur_board), (function (isMatch) {
                return isMatch;
              }));
}

function matches_any_pattern(board_state, patterns) {
  return Belt_Array.keep(Belt_Array.mapWithIndex(patterns, (function (i, pattern) {
                    return /* tuple */[
                            i,
                            matches_any_rot(board_state, pattern)
                          ];
                  })), (function (param) {
                return param[1];
              }));
}

function modify_slot(board_state, position, state) {
  var set_cur_board = function (x, y, value) {
    return Utils.set_unsafe(board_state, x, y, value);
  };
  switch (state) {
    case 0 : 
        set_cur_board(position[/* x */0], position[/* y */1], 1);
        return /* NEW */2;
    case 1 : 
        set_cur_board(position[/* x */0], position[/* y */1], 0);
        return /* EMPTY */0;
    case 2 : 
        return /* NEW */2;
    case 3 : 
        return /* LOCKED */3;
    
  }
}

var scene = new Phaser.Scene({
      key: "board"
    });

var board = Utils.map_matrix(Utils.get_n_m_board(6, 6, 0), (function (param) {
        return create_board_entry(undefined, undefined, undefined, undefined, undefined, /* () */0);
      }));

function set_board(x, y, value) {
  return Utils.set_unsafe(board, x, y, value);
}

function get_board(x, y) {
  return Utils.get_unsafe(board, x, y);
}

function draw_board($staropt$star, $staropt$star$1, w) {
  var x_offset = $staropt$star !== undefined ? $staropt$star : 0.0;
  var y_offset = $staropt$star$1 !== undefined ? $staropt$star$1 : 0.0;
  var object_factor = scene.add;
  var board_container = object_factor.container();
  var grid_w_f = 6;
  var grid_h_f = 6;
  var s_width = w / grid_w_f;
  var s_height = w / grid_h_f;
  for(var i = 0 ,i_finish = (grid_w_f | 0) - 1 | 0; i <= i_finish; ++i){
    for(var j = 0 ,j_finish = (grid_h_f | 0) - 1 | 0; j <= j_finish; ++j){
      var slot = object_factor.graphics();
      var fillColor = parseInt(Utils.get_unsafe(Utils.color_map, j, i), 16);
      var s_x = j * s_width;
      var s_y = i * s_height;
      var hit_zone = object_factor.zone(s_x + 0.5 * s_width, s_y + 0.5 * s_height, s_width, s_height);
      slot.lineStyle(5.0, 0, 1.0);
      slot.fillStyle(fillColor, 1.0);
      slot.beginPath();
      if (i === 0) {
        slot.moveTo(s_x, s_y);
        var param = s_x + s_width;
        slot.lineTo(param, s_y);
      }
      var param$1 = s_x + s_width;
      slot.moveTo(param$1, s_y);
      var param$2 = s_y + s_height;
      var param$3 = s_x + s_width;
      slot.lineTo(param$3, param$2);
      var param$4 = s_y + s_height;
      slot.lineTo(s_x, param$4);
      if (j === 0) {
        slot.lineTo(s_x, s_y);
      }
      var param$5 = i * s_height;
      var param$6 = j * s_width;
      slot.fillRect(param$6, param$5, s_width, s_height);
      slot.strokePath();
      hit_zone.setInteractive();
      board_container.add(slot);
      board_container.add(hit_zone);
      var init = Utils.get_unsafe(board, i, j);
      set_board(i, j, /* record */[
            /* value */init[/* value */0],
            /* zone */Caml_option.some(hit_zone),
            /* graphics */Caml_option.some(slot),
            /* state */init[/* state */3],
            /* sprite */init[/* sprite */4]
          ]);
    }
  }
  board_container.setPosition(x_offset, y_offset);
  return /* () */0;
}

function preload(param) {
  var load_image = function (key, dest) {
    scene.load.image(key, dest);
    return /* () */0;
  };
  load_image("marble", "tileGrey_30.png");
  return load_image("check", "green_checkmark.png");
}

function lock_slot(x, y) {
  var init = Utils.get_unsafe(board, x, y);
  return set_board(x, y, /* record */[
              /* value */init[/* value */0],
              /* zone */init[/* zone */1],
              /* graphics */init[/* graphics */2],
              /* state : LOCKED */3,
              /* sprite */init[/* sprite */4]
            ]);
}

function lock_row(idx) {
  if (idx < 6) {
    for(var i = 0; i <= 5; ++i){
      lock_slot(i, idx);
    }
    return /* () */0;
  } else {
    return 0;
  }
}

function lock_col(idx) {
  if (idx < 6) {
    for(var j = 0; j <= 5; ++j){
      lock_slot(idx, j);
    }
    return /* () */0;
  } else {
    return 0;
  }
}

function handle_slot_clicked(param) {
  return /* () */0;
}

function add_board_events(param) {
  var add_click_callback = function (entry) {
    var match = entry[/* zone */1];
    if (match !== undefined) {
      Caml_option.valFromOption(match).on("pointerdown", handle_slot_clicked);
      return /* () */0;
    } else {
      return /* () */0;
    }
  };
  return Utils.for_each_matrix(board, add_click_callback);
}

function restrict_board(param) {
  if (Belt_List.length(players) < 4) {
    lock_row(5);
    lock_col(5);
  }
  if (Belt_List.length(players) < 3) {
    lock_row(0);
    return lock_col(0);
  } else {
    return 0;
  }
}

function create_scores(param) {
  var object_factory = scene.add;
  var style = {
    fill: "#000",
    fontSize: "16px"
  };
  return Belt_Array.mapWithIndex(Belt_Array.make(5, 0), (function (idx, param) {
                return object_factory.text(16, 16 + (idx << 4) | 0, "todo", style);
              }));
}

function create(param) {
  var c = scene.sys.canvas;
  var w = c.width;
  var h = c.height;
  var board_width = w * 0.8;
  draw_board(0.1 * w, 0.15 * h, board_width);
  create_scores(/* () */0);
  return restrict_board(/* () */0);
}

function handle_move(param) {
  console.log("working", param[/* last_move */0]);
  return /* () */0;
}

function init(_config) {
  config[0] = _config;
  return Curry._2(config[0][/* subscribe */2], State.move_event, handle_move);
}

var state = State.init(/* () */0);

var match = State.subscribe(Belt_MapString.empty, State.move_event, handle_move);

var listeners = match[0];

console.log(State.dispatch(state, listeners, State.move_event, /* MOVE */Block.__(0, [/* record */[
              /* x */2,
              /* y */2,
              /* next_player */"2"
            ]])));

console.log(listeners);

scene.create = create;

var grid_w = 6;

var grid_h = 6;

var $$default = scene;

var listeners$1 = Belt_MapString.empty;

export {
  grid_w ,
  grid_h ,
  players ,
  config ,
  init_marble ,
  create_board_entry ,
  has_match ,
  matches_any_rot ,
  matches_any_pattern ,
  modify_slot ,
  scene ,
  board ,
  set_board ,
  get_board ,
  draw_board ,
  preload ,
  lock_slot ,
  lock_row ,
  lock_col ,
  handle_slot_clicked ,
  add_board_events ,
  restrict_board ,
  create_scores ,
  create ,
  handle_move ,
  init ,
  $$default ,
  $$default as default,
  state ,
  listeners$1 as listeners,
  
}
/* players Not a pure module */
