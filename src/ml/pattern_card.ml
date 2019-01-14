open Phaser
open GameObject
open Utils 

let grid_h = 3 

let grid_w = 3

let create_marble factory x y w h = 
  let marble = sprite factory x y "marble" in
  Sprite.displayWidthSet marble w;
  Sprite.displayHeightSet marble h;
  marble

let draw_card scene pattern x y w h = 
  Js.log2 "pattern" pattern;

  let object_factor = Scene.addGet scene in
  let card_container = container object_factor in
  let grid_w_f = float_of_int grid_w in
  let grid_h_f = float_of_int grid_h in
  let s_width = w /. grid_w_f in
  let s_height = h /. grid_h_f in
  let {width = m_width; height = m_height} = Utils.scale_marble_size s_width s_height 30.0 in
  for i = 0 to int_of_float grid_w_f - 1 do
    for j = 0 to int_of_float grid_h_f - 1 do
      let slot = graphics object_factor in
      let apply f = slot |. f in
      let s_x = float_of_int j *. s_width in
      let s_y = float_of_int i *. s_height in
      apply Graphics.lineStyle 5.0 (parse_int "E1E2E1" 16) 1.0 ;
      apply Graphics.fillStyle (parse_int "bbdefb" 16) 1.0 ;
      apply Graphics.beginPath ;
      (* draw top border if needed *)
      if i = 0 then (
        apply Graphics.moveTo s_x s_y ;
        apply Graphics.lineTo (s_x +. s_width) s_y ) ;
      (* draw right and bottom border *)
      apply Graphics.moveTo (s_x +. s_width) s_y ;
      apply Graphics.lineTo (s_x +. s_width) (s_y +. s_height) ;
      apply Graphics.lineTo s_x (s_y +. s_height) ;
      if j = 0 then apply Graphics.lineTo s_x s_y ;
      apply Graphics.fillRect
        (float_of_int j *. s_width)
        (float_of_int i *. s_height)
        s_width s_height ;
      apply Graphics.strokePath ;
      add_container card_container (`Graphics slot) ;
      Js.log3 i j pattern;
      if get_unsafe pattern i j = 1.0 then (
        let marble_sprite = create_marble object_factor 
          (s_x +. s_width *. 0.5) (s_y +. s_height *. 0.5) m_width m_height in 
        add_container card_container (`Sprite marble_sprite)  
        )
    done
  done ;
  Container.set_position card_container x y