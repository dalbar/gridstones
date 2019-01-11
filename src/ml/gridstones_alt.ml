open Phaser
open Belt

type coordinates = {x: int; y: int}

type size = {width: float; height: float}

external parse_int : string -> int -> int = "parseInt" [@@bs.val]

module Generator = struct
  open Node.Fs

  exception DIM of string

  let generate_one_stone_permutations row =
    let fill_copy idx =
      Array.copy row |. fun row -> Array.setExn row idx 1 ; row
    in
    let rec loop perm idx =
      try
        let cur_value = Array.getExn row idx in
        match cur_value with
        | -1 -> List.add perm (fill_copy idx) |. loop (idx + 1)
        | _ -> loop perm (idx + 1)
      with _ -> perm
    in
    loop (List.make 0 row) 0

  let filter_dups_from_list perm =
    let no_dup = List.make 0 (Array.make 0 0) in
    List.reduce perm no_dup (fun acc row ->
        if List.has acc row (fun l1 l2 -> Array.eq l1 l2 ( = )) then acc
        else List.add acc row )

  let generate_row_permutations size max_stones =
    let empty_row = Array.make size (-1) in
    let res = List.make 1 empty_row in
    let rec loop cur_stones latest_rows res =
      if cur_stones > max_stones then res
      else
        let new_rows =
          List.map latest_rows (fun row -> generate_one_stone_permutations row)
          |. List.flatten
        in
        loop (cur_stones + 1) new_rows (List.concat res latest_rows)
    in
    let with_dup = loop 0 res (List.make (-1) empty_row) in
    filter_dups_from_list with_dup

  let append_matrix matrix rows =
    let res = List.make 0 (Array.make 0 0) in
    List.reduce rows res (fun acc row ->
        Array.concat matrix row |> List.add acc )

  let shape_quad m array =
    let len = Array.length array in
    if len mod m > 0 then raise (DIM "Dimensions do not match!")
    else
      let res = Array.make (len / m) (Array.make 0 0) in
      let rec loop cur_idx =
        if cur_idx > len - m then ()
        else
          let new_row = Array.slice array ~offset:cur_idx ~len:m in
          Array.setExn res (cur_idx / m) new_row ;
          loop (cur_idx + m)
      in
      loop 0 ; res

  let has_at_least_n_stones array n =
    Array.reduce array 0 (fun acc value -> if value = 1 then acc + 1 else acc)
    |. ( >= ) n

  let generate_pattern ?(min_stones = 0) size max_stones =
    let rows = generate_row_permutations size max_stones in
    let rec loop cur_rows res =
      if cur_rows = size then res
      else
        let new_res =
          List.map res (fun matrix -> append_matrix matrix rows)
          |. List.flatten
        in
        loop (cur_rows + 1) new_res
    in
    loop 1 rows |. filter_dups_from_list
    |. List.keep (fun array -> has_at_least_n_stones array min_stones)
    |. List.map (fun matrix -> shape_quad size matrix)

  let write_deck deck dest = writeFileSync dest deck `ascii

  let get_unsafe matrix x_ind y_ind =
    Array.getExn matrix y_ind |. Array.getExn x_ind

  let set_unsafe matrix x_ind y_ind value =
    Array.getExn matrix y_ind |. Array.setExn x_ind value

  let rot90_square matrix =
    let dim = Array.length matrix in
    let rotated = Array.make dim (-1) |. Array.map (Array.make dim) in
    for i = 0 to dim - 1 do
      for j = 0 to dim - 1 do
        get_unsafe matrix j i |> set_unsafe rotated (dim - i - 1) j
      done
    done ;
    rotated

  let get_array_dim m1 =
    let m = Array.length m1 in
    let n = Array.length (Array.getExn m1 0) in
    (n, m)

  let get_all_rots m =
    let m_rot_90 = rot90_square m in
    let m_rot_180 = rot90_square m_rot_90 in
    let m_rot_270 = rot90_square m_rot_180 in
    [m; m_rot_90; m_rot_180; m_rot_270]

  let cmp_matrix_square m1 m2 =
    let dim = Array.length m1 in
    let rec loop idx =
      if idx = dim then 1
      else
        let row_m1 = Array.getExn m1 idx in
        let row_m2 = Array.getExn m2 idx in
        if Array.eq row_m1 row_m2 ( = ) then loop (idx + 1) else -1
    in
    loop 0

  let eq_matrix_square m1 m2 =
    if cmp_matrix_square m1 m2 = 1 then true else false

  let is_rot_equal m1 m2 =
    let rec loop matrices =
      match matrices with
      | [] -> false
      | y :: ys -> if eq_matrix_square m1 y then true else loop ys
    in
    get_all_rots m2 |. loop

  let make_n_m_matrix n m = Array.make n 0 |. Array.map (Array.make m)

  let filter_rot_equal matrices =
    let not_rot_equal = List.make 0 (make_n_m_matrix 0 0) in
    List.reduce matrices not_rot_equal (fun acc row ->
        if List.has acc row is_rot_equal then acc else List.add acc row )
end

module Utils = struct
  open Array

  (** Transform between world coordinates (origin at top left corner) and image coordinates (origin at center) *)
  let transform_world_to_image_coords x y canvas_width canvas_height =
    {x= (canvas_width / 2) + x; y= (canvas_height / 2) + y}

  let get_n_m_board n m = make m 0 |. map (make n)

  let scale_marble_size board_width board_height p =
    {width= (board_width /. 6.0) -. p; height= (board_height /. 6.0) -. p}

  let dot_product m1 m2 =
    let flattened_m1 = concatMany m1 in
    let flattened_m2 = concatMany m2 in
    reduce (zip flattened_m1 flattened_m2) 0 (fun acc (a, b) -> (a * b) + acc)

  let sub_matrix m ?(x_offset = 0) ?(y_offset = 0) x_len y_len =
    let extracted_y = slice m ~offset:y_offset ~len:y_len in
    map extracted_y (fun row -> slice row ~offset:x_offset ~len:x_len)

  let conv aoi filter =
    let y_size = length filter in
    let x_size = getExn filter 0 |. length in
    let y_size_half = (y_size - 1) / 2 in
    let x_size_half = (x_size - 1) / 2 in
    mapWithIndex aoi (fun i row ->
        mapWithIndex row (fun j _ ->
            if i - y_size_half < 0 || j - x_size_half < 0 then 0
            else
              sub_matrix aoi ~x_offset:(j - x_size_half)
                ~y_offset:(i - y_size_half) x_size y_size
              |. dot_product filter ) )

  let color_map =
    let res = make 6 "42a5f5" |. map (make 6) in
    let set_color x y =
      let set_color value = Generator.set_unsafe res x y value in
      match (x, y, x < 5, y < 5) with
      | 0, _, true, true -> set_color "fdd835"
      | _, 0, true, true -> set_color "fdd835"
      | _, 5, _, _ -> set_color "ff5722"
      | 5, _, _, _ -> set_color "ff5722"
      | _ -> set_color "42a5f5"
    in
    forEachWithIndex res (fun y rows ->
        forEachWithIndex rows (fun x _ -> set_color x y) ) ;
    res
end

module Board = struct
  open Scene
  open GameObject
  
  type states = EMPTY | PLACED | NEW | LOCKED

  let grid_w = 6.0

  let grid_h = 6.0

  let has_match board_state pattern =
    let num_stones =
      Array.concatMany pattern
      |. Array.reduce 0 (fun acc slot -> if slot = 1 then acc + 1 else acc)
    in
    Utils.conv board_state pattern
    |. Array.concatMany
    |. Array.some (fun e -> e = num_stones)

  let matches_any_rot board_state pattern =
    let matches_cur_board p = has_match board_state p in
    Generator.get_all_rots pattern
    |. List.map matches_cur_board
    |. List.some (fun isMatch -> isMatch)

  let matches_any_pattern board_state patterns =
    Array.mapWithIndex patterns (fun i pattern ->
        (i, matches_any_rot board_state pattern) )
    |. Array.keep (fun (_, hasMatch) -> hasMatch)

  let modify_slot board_state position state =
    let set_cur_board x y value = Generator.set_unsafe board_state x y value in
    match state with
    | EMPTY ->
        set_cur_board position.x position.y 1 ;
        NEW
    | PLACED ->
        set_cur_board position.x position.y 0 ;
        EMPTY
    | NEW -> NEW
    | LOCKED -> LOCKED

  let scene = config ~key:"board" |. create

  let gameObjectFactory = addGet scene

  let draw_board ?(x_offset = 0.0) ?(y_offset = 0.0) w h =
    let board_container = container gameObjectFactory in
    let s_width = w /. grid_w in
    let s_height = w /. grid_h in
    for i = 0 to int_of_float grid_w do
      for j = 0 to int_of_float grid_h do
        let slot = graphics gameObjectFactory in
        let apply f = slot |. f in
        let fillColor =
          Generator.get_unsafe Utils.color_map j i |. parse_int 16
        in
        let s_x = float_of_int j *. s_width in
        let s_y = float_of_int i *. s_height in
        let hit_zone =
          zone gameObjectFactory
            ( s_x +. (0.5 *. s_width)
            , s_y +. (0.5 *. s_height)
            , s_width
            , s_height )
        in

        apply Graphics.lineStyle (5, 1.0) ;
        apply Graphics.fillStyle (fillColor, 1.0) ;
        apply Graphics.beginPath ;

        (* draw top border if needed *)        
        if i = 0 then (
          apply Graphics.moveTo (s_x, s_y) ;
          apply Graphics.lineTo (s_x +. s_width, s_y) );
        
        (* draw right and bottom border *)
        apply Graphics.moveTo (s_x +. s_width, s_y);
        apply Graphics.lineTo (s_x +. s_width, s_y +. s_height);
        apply Graphics.lineTo (s_x, s_y +. s_height);

        if j = 0 then (
          apply Graphics.lineTo (s_x, s_y);
        );

        apply Graphics.fillRect (float_of_int(j) *. s_width, float_of_int(i) *. s_height, s_width, s_height);
        apply Graphics.strokePath;
        set_interactive_zone hit_zone;
        add_container board_container (`Graphics slot);
        add_container board_container (`Zone hit_zone);
      done
    done;
    Container.set_position board_container (x_offset, y_offset)

  let create =
    let sys = sysGet scene in
    let board_width = sys.canvas.width *. 0.8 in
    let board_height = sys.canvas.width *. 0.8 in
    draw_board board_width board_height
end

module State = struct
  let moveAction = "MOVE"

  let idAction = "ID"

  let playersAction = "PLAYERS"

  let turnAction = "TURN"

  let gamePhaseAction = "PHASE"

  let handAction = "HAND"

  let winnerAction = "WINNER"

  let initMap () = Belt_MapString.empty

  let update_state state key data = Belt_MapString.set state key data

  let dispatch state listeners key data =
    let new_state = update_state state key data in
    if Belt_MapString.has listeners key then
      Belt_MapString.getExn listeners key
      |. Array.forEach (fun fn -> fn new_state) ;
    new_state

  let subscribe listeners event fn =
    let new_list =
      try
        let cur_listeners = Belt_MapString.getExn listeners event in
        Array.make 1 fn |> Array.concat cur_listeners
      with _ -> Array.make 1 fn
    in
    let newIndex = Array.length new_list in
    (Belt_MapString.set listeners event new_list, newIndex)

  let unsubscribe listeners event idx =
    try
      Belt_MapString.getExn listeners event
      |. Array.keepWithIndex (fun _ i -> i = idx)
      |> Belt_MapString.set listeners event
    with _ -> listeners

  let get_value state key = Belt_MapString.getExn state key
end
