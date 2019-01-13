// Generated by BUCKLESCRIPT VERSION 4.0.14, PLEASE EDIT WITH CARE

import * as Curry from "../../node_modules/bs-platform/lib/es6/curry.js";
import * as State from "./state.bs.js";
import * as Belt_Array from "../../node_modules/bs-platform/lib/es6/belt_Array.js";
import * as Caml_array from "../../node_modules/bs-platform/lib/es6/caml_array.js";
import * as Caml_int32 from "../../node_modules/bs-platform/lib/es6/caml_int32.js";

function transform_world_to_image_coords(x, y, canvas_width, canvas_height) {
  return /* record */[
          /* x */(canvas_width / 2 | 0) + x | 0,
          /* y */(canvas_height / 2 | 0) + y | 0
        ];
}

function get_n_m_board(n, m, v) {
  return Belt_Array.map(Belt_Array.make(m, v), (function (param) {
                return Belt_Array.make(n, param);
              }));
}

function scale_marble_size(board_width, board_height, p) {
  return /* record */[
          /* width */board_width / 6.0 - p,
          /* height */board_height / 6.0 - p
        ];
}

function dot_product(m1, m2) {
  var flattened_m1 = Belt_Array.concatMany(m1);
  var flattened_m2 = Belt_Array.concatMany(m2);
  return Belt_Array.reduce(Belt_Array.zip(flattened_m1, flattened_m2), 0, (function (acc, param) {
                return Caml_int32.imul(param[0], param[1]) + acc | 0;
              }));
}

function sub_matrix(m, $staropt$star, $staropt$star$1, x_len, y_len) {
  var x_offset = $staropt$star !== undefined ? $staropt$star : 0;
  var y_offset = $staropt$star$1 !== undefined ? $staropt$star$1 : 0;
  var extracted_y = Belt_Array.slice(m, y_offset, y_len);
  return Belt_Array.map(extracted_y, (function (row) {
                return Belt_Array.slice(row, x_offset, x_len);
              }));
}

function conv(aoi, filter) {
  var y_size = filter.length;
  var x_size = Caml_array.caml_array_get(filter, 0).length;
  var y_size_half = (y_size - 1 | 0) / 2 | 0;
  var x_size_half = (x_size - 1 | 0) / 2 | 0;
  return Belt_Array.mapWithIndex(aoi, (function (i, row) {
                return Belt_Array.mapWithIndex(row, (function (j, param) {
                              if ((i - y_size_half | 0) < 0 || (j - x_size_half | 0) < 0) {
                                return 0;
                              } else {
                                return dot_product(sub_matrix(aoi, j - x_size_half | 0, i - y_size_half | 0, x_size, y_size), filter);
                              }
                            }));
              }));
}

var res = Belt_Array.map(Belt_Array.make(6, "42a5f5"), (function (param) {
        return Belt_Array.make(6, param);
      }));

Belt_Array.forEachWithIndex(res, (function (y, rows) {
        return Belt_Array.forEachWithIndex(rows, (function (x, param) {
                      var x$1 = x;
                      var y$1 = y;
                      var match = x$1 < 5;
                      var match$1 = y$1 < 5;
                      var exit = 0;
                      var exit$1 = 0;
                      if (x$1 !== 0 || !(match && match$1)) {
                        exit$1 = 2;
                      } else {
                        return Caml_array.caml_array_set(Caml_array.caml_array_get(res, x$1), y$1, "fdd835");
                      }
                      if (exit$1 === 2) {
                        if (y$1 !== 0) {
                          if (y$1 !== 5) {
                            exit = 1;
                          } else {
                            return Caml_array.caml_array_set(Caml_array.caml_array_get(res, x$1), y$1, "ff5722");
                          }
                        } else if (match && match$1) {
                          return Caml_array.caml_array_set(Caml_array.caml_array_get(res, x$1), y$1, "fdd835");
                        } else {
                          exit = 1;
                        }
                      }
                      if (exit === 1) {
                        if (x$1 !== 5) {
                          return Caml_array.caml_array_set(Caml_array.caml_array_get(res, x$1), y$1, "42a5f5");
                        } else {
                          return Caml_array.caml_array_set(Caml_array.caml_array_get(res, x$1), y$1, "ff5722");
                        }
                      }
                      
                    }));
      }));

function get_board_idx(x, y, grid_h) {
  return y * grid_h + x;
}

function map_matrix_with_index(matrix, f) {
  return Belt_Array.mapWithIndex(matrix, (function (j, row) {
                return Belt_Array.mapWithIndex(row, (function (i, entry) {
                              return Curry._3(f, i, j, entry);
                            }));
              }));
}

function map_matrix(matrix, f) {
  return map_matrix_with_index(matrix, (function (param, param$1, entry) {
                return Curry._1(f, entry);
              }));
}

function for_each_matrix_with_index(matrix, f) {
  return Belt_Array.forEachWithIndex(matrix, (function (j, row) {
                return Belt_Array.forEachWithIndex(row, (function (i, entry) {
                              return Curry._3(f, i, j, entry);
                            }));
              }));
}

function for_each_matrix(matrix, f) {
  return for_each_matrix_with_index(matrix, (function (param, param$1, entry) {
                return Curry._1(f, entry);
              }));
}

function get_unsafe(matrix, x_ind, y_ind) {
  return Belt_Array.getExn(Belt_Array.getExn(matrix, y_ind), x_ind);
}

function set_unsafe(matrix, x_ind, y_ind, value) {
  return Belt_Array.setExn(Belt_Array.getExn(matrix, y_ind), x_ind, value);
}

function init_config($staropt$star, $staropt$star$1, $staropt$star$2, $staropt$star$3, $staropt$star$4, $staropt$star$5, param) {
  var state = $staropt$star !== undefined ? $staropt$star : State.init(/* () */0);
  var subscribe = $staropt$star$1 !== undefined ? $staropt$star$1 : (function (param, param$1) {
        return -1;
      });
  var send_move = $staropt$star$2 !== undefined ? $staropt$star$2 : (function (param, param$1) {
        return /* () */0;
      });
  var send_winner = $staropt$star$3 !== undefined ? $staropt$star$3 : (function (param) {
        return /* () */0;
      });
  var handle_register = $staropt$star$4 !== undefined ? $staropt$star$4 : (function (param) {
        return /* () */0;
      });
  var send_start = $staropt$star$5 !== undefined ? $staropt$star$5 : (function (param) {
        return /* () */0;
      });
  return /* record */[
          /* state */state,
          /* subscribe */subscribe,
          /* send_move */send_move,
          /* send_winner */send_winner,
          /* handle_register */handle_register,
          /* send_start */send_start
        ];
}

var color_map = res;

export {
  transform_world_to_image_coords ,
  get_n_m_board ,
  scale_marble_size ,
  dot_product ,
  sub_matrix ,
  conv ,
  color_map ,
  get_board_idx ,
  map_matrix_with_index ,
  map_matrix ,
  for_each_matrix_with_index ,
  for_each_matrix ,
  get_unsafe ,
  set_unsafe ,
  init_config ,
  
}
/* res Not a pure module */
