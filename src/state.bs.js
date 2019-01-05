// Generated by BUCKLESCRIPT VERSION 4.0.14, PLEASE EDIT WITH CARE

import * as Curry from "./../node_modules/bs-platform/lib/es6/curry.js";
import * as Belt_Array from "./../node_modules/bs-platform/lib/es6/belt_Array.js";
import * as Belt_MapString from "./../node_modules/bs-platform/lib/es6/belt_MapString.js";

function initMap(param) {
  return Belt_MapString.empty;
}

var update_state = Belt_MapString.set;

function dispatch(state, listeners, key, data) {
  var new_state = Belt_MapString.set(state, key, data);
  if (Belt_MapString.has(listeners, key)) {
    Belt_Array.forEach(Belt_MapString.getExn(listeners, key), (function (fn) {
            return Curry._1(fn, new_state);
          }));
  }
  return new_state;
}

function subscribe(listeners, $$event, fn) {
  var new_list;
  try {
    var cur_listeners = Belt_MapString.getExn(listeners, $$event);
    new_list = Belt_Array.concat(cur_listeners, Belt_Array.make(1, fn));
  }
  catch (exn){
    new_list = Belt_Array.make(1, fn);
  }
  var newIndex = new_list.length;
  return /* tuple */[
          Belt_MapString.set(listeners, $$event, new_list),
          newIndex
        ];
}

function unsubscribe(listeners, $$event, idx) {
  try {
    return Belt_MapString.set(listeners, $$event, Belt_Array.keepWithIndex(Belt_MapString.getExn(listeners, $$event), (function (param, i) {
                      return i === idx;
                    })));
  }
  catch (exn){
    return listeners;
  }
}

var get_value = Belt_MapString.getExn;

var moveAction = "MOVE";

var idAction = "ID";

var playersAction = "PLAYERS";

export {
  moveAction ,
  idAction ,
  playersAction ,
  initMap ,
  update_state ,
  dispatch ,
  subscribe ,
  unsubscribe ,
  get_value ,
  
}
/* No side effect */
