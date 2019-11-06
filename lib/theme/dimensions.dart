import 'package:flutter/material.dart';

const double grid_spacer = 8.0;

// ---------------------------------
// Margins (All)
// ---------------------------------
const margin_none = EdgeInsets.all(0);
const margin_a_xxs = EdgeInsets.all(grid_spacer);
const margin_a_xs = EdgeInsets.all(grid_spacer * 2);
const margin_a_s = EdgeInsets.all(grid_spacer * 3);
const margin_a_m = EdgeInsets.all(grid_spacer * 4);
const margin_a_l = EdgeInsets.all(grid_spacer * 5);
const margin_a_xl = EdgeInsets.all(grid_spacer * 6);
const margin_a_xxl = EdgeInsets.all(grid_spacer * 7);

// Margins (X-Axis)
const margin_x_none = EdgeInsets.symmetric(horizontal: 0);
const margin_x_xxs = EdgeInsets.symmetric(horizontal: grid_spacer);
const margin_x_xs = EdgeInsets.symmetric(horizontal: grid_spacer * 2);
const margin_x_s = EdgeInsets.symmetric(horizontal: grid_spacer * 3);
const margin_x_m = EdgeInsets.symmetric(horizontal: grid_spacer * 4);
const margin_x_l = EdgeInsets.symmetric(horizontal: grid_spacer * 5);
const margin_x_xl = EdgeInsets.symmetric(horizontal: grid_spacer * 6);
const margin_x_xxl = EdgeInsets.symmetric(horizontal: grid_spacer * 7);

// Margins (Y-Axis)
const margin_y_none = EdgeInsets.symmetric(vertical: 0);
const margin_y_xxs = EdgeInsets.symmetric(vertical: grid_spacer);
const margin_y_xs = EdgeInsets.symmetric(vertical: grid_spacer * 2);
const margin_y_s = EdgeInsets.symmetric(vertical: grid_spacer * 3);
const margin_y_m = EdgeInsets.symmetric(vertical: grid_spacer * 4);
const margin_y_l = EdgeInsets.symmetric(vertical: grid_spacer * 5);
const margin_y_xl = EdgeInsets.symmetric(vertical: grid_spacer * 6);
const margin_y_xxl = EdgeInsets.symmetric(vertical: grid_spacer * 7);

// Margins (Top)
const margin_top_none = EdgeInsets.only(top: 0);
const margin_top_xxs = EdgeInsets.fromLTRB(0, grid_spacer, 0, 0);
const margin_top_xs = EdgeInsets.fromLTRB(0, grid_spacer * 2, 0, 0);
const margin_top_s = EdgeInsets.fromLTRB(0, grid_spacer * 3, 0, 0);
const margin_top_m = EdgeInsets.fromLTRB(0, grid_spacer * 4, 0, 0);
const margin_top_l = EdgeInsets.fromLTRB(0, grid_spacer * 5, 0, 0);
const margin_top_xl = EdgeInsets.fromLTRB(0, grid_spacer * 6, 0, 0);
const margin_top_xxl = EdgeInsets.fromLTRB(0, grid_spacer * 7, 0, 0);

// Margins (Right)
const margin_right_none = EdgeInsets.only(right: 0);
const margin_right_xxs = EdgeInsets.fromLTRB(0, 0, grid_spacer, 0);
const margin_right_xs = EdgeInsets.fromLTRB(0, 0, grid_spacer * 2, 0);
const margin_right_s = EdgeInsets.fromLTRB(0, 0, grid_spacer * 3, 0);
const margin_right_m = EdgeInsets.fromLTRB(0, 0, grid_spacer * 4, 0);
const margin_right_l = EdgeInsets.fromLTRB(0, 0, grid_spacer * 5, 0);
const margin_right_xl = EdgeInsets.fromLTRB(0, 0, grid_spacer * 6, 0);
const margin_right_xxl = EdgeInsets.fromLTRB(0, 0, grid_spacer * 7, 0);

// Margins (Bottom)
const margin_bottom_none = EdgeInsets.only(bottom: 0);
const margin_bottom_xxs = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer);
const margin_bottom_xs = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 2);
const margin_bottom_s = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 3);
const margin_bottom_m = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 4);
const margin_bottom_l = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 5);
const margin_bottom_xl = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 6);
const margin_bottom_xxl = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 7);

// Margins (Left)
const margin_left_none = EdgeInsets.only(left: 0);
const margin_left_xxs = EdgeInsets.fromLTRB(grid_spacer, 0, 0, 0);
const margin_left_xs = EdgeInsets.fromLTRB(grid_spacer * 2, 0, 0, 0);
const margin_left_s = EdgeInsets.fromLTRB(grid_spacer * 3, 0, 0, 0);
const margin_left_m = EdgeInsets.fromLTRB(grid_spacer * 4, 0, 0, 0);
const margin_left_l = EdgeInsets.fromLTRB(grid_spacer * 5, 0, 0, 0);
const margin_left_xl = EdgeInsets.fromLTRB(grid_spacer * 6, 0, 0, 0);
const margin_left_xxl = EdgeInsets.fromLTRB(grid_spacer * 7, 0, 0, 0);


// ---------------------------------
// Paddings (All)
// ---------------------------------


const padding_none = EdgeInsets.all(0);
/// grid_spacer * 0.5
const padding_a_xxxs = EdgeInsets.all(grid_spacer * 0.5);
/// grid_spacer * 1
const padding_a_xxs = EdgeInsets.all(grid_spacer);
/// grid_spacer * 2
const padding_a_xs = EdgeInsets.all(grid_spacer * 2);
/// grid_spacer * 3
const padding_a_s = EdgeInsets.all(grid_spacer * 3);
/// grid_spacer * 4
const padding_a_m = EdgeInsets.all(grid_spacer * 4);
/// grid_spacer * 5
const padding_a_l = EdgeInsets.all(grid_spacer * 5);
/// grid_spacer * 6
const padding_a_xl = EdgeInsets.all(grid_spacer * 6);
/// grid_spacer * 7
const padding_a_xxl = EdgeInsets.all(grid_spacer * 7);

// Paddings (X-Axis)
const padding_x_none = EdgeInsets.symmetric(horizontal: 0);
/// grid_spacer * 1
const padding_x_xxs = EdgeInsets.symmetric(horizontal: grid_spacer);
/// grid_spacer * 2
const padding_x_xs = EdgeInsets.symmetric(horizontal: grid_spacer * 2);
/// grid_spacer * 3
const padding_x_s = EdgeInsets.symmetric(horizontal: grid_spacer * 3);
/// grid_spacer * 4
const padding_x_m = EdgeInsets.symmetric(horizontal: grid_spacer * 4);
/// grid_spacer * 5
const padding_x_l = EdgeInsets.symmetric(horizontal: grid_spacer * 5);
/// grid_spacer * 6
const padding_x_xl = EdgeInsets.symmetric(horizontal: grid_spacer * 6);
/// grid_spacer * 7
const padding_x_xxl = EdgeInsets.symmetric(horizontal: grid_spacer * 7);

// Paddings (Y-Axis)
const padding_y_none = EdgeInsets.symmetric(vertical: 0);
/// grid_spacer * 0.5
const padding_y_xxxs = EdgeInsets.symmetric(vertical: grid_spacer * 0.5);
/// grid_spacer * 1
const padding_y_xxs = EdgeInsets.symmetric(vertical: grid_spacer);
/// grid_spacer * 2
const padding_y_xs = EdgeInsets.symmetric(vertical: grid_spacer * 2);
/// grid_spacer * 3
const padding_y_s = EdgeInsets.symmetric(vertical: grid_spacer * 3);
/// grid_spacer * 4
const padding_y_m = EdgeInsets.symmetric(vertical: grid_spacer * 4);
/// grid_spacer * 5
const padding_y_l = EdgeInsets.symmetric(vertical: grid_spacer * 5);
/// grid_spacer * 6
const padding_y_xl = EdgeInsets.symmetric(vertical: grid_spacer * 6);
/// grid_spacer * 7
const padding_y_xxl = EdgeInsets.symmetric(vertical: grid_spacer * 7);

// Paddings (Top)
const padding_top_none = EdgeInsets.only(top: 0);
/// grid_spacer * 1
const padding_top_xxs = EdgeInsets.fromLTRB(0, grid_spacer, 0, 0);
const padding_top_xs = EdgeInsets.fromLTRB(0, grid_spacer * 2, 0, 0);
/// grid_spacer * 2
const padding_top_s = EdgeInsets.fromLTRB(0, grid_spacer * 3, 0, 0);
/// grid_spacer * 3
const padding_top_m = EdgeInsets.fromLTRB(0, grid_spacer * 4, 0, 0);
/// grid_spacer * 4
const padding_top_l = EdgeInsets.fromLTRB(0, grid_spacer * 5, 0, 0);
/// grid_spacer * 5
const padding_top_xl = EdgeInsets.fromLTRB(0, grid_spacer * 6, 0, 0);
/// grid_spacer * 6
const padding_top_xxl = EdgeInsets.fromLTRB(0, grid_spacer * 7, 0, 0);
/// grid_spacer * 7

// Paddings (Right)
const padding_right_none = EdgeInsets.only(right: 0);
/// grid_spacer * 1
const padding_right_xxs = EdgeInsets.fromLTRB(0, 0, grid_spacer, 0);
/// grid_spacer * 2
const padding_right_xs = EdgeInsets.fromLTRB(0, 0, grid_spacer * 2, 0);
/// grid_spacer * 3
const padding_right_s = EdgeInsets.fromLTRB(0, 0, grid_spacer * 3, 0);
/// grid_spacer * 4
const padding_right_m = EdgeInsets.fromLTRB(0, 0, grid_spacer * 4, 0);
/// grid_spacer * 5
const padding_right_l = EdgeInsets.fromLTRB(0, 0, grid_spacer * 5, 0);
/// grid_spacer * 6
const padding_right_xl = EdgeInsets.fromLTRB(0, 0, grid_spacer * 6, 0);
/// grid_spacer * 7
const padding_right_xxl = EdgeInsets.fromLTRB(0, 0, grid_spacer * 7, 0);

// Paddings (Bottom)
const padding_bottom_none = EdgeInsets.only(bottom: 0);
/// grid_spacer * 1
const padding_bottom_xxs = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer);
/// grid_spacer * 2
const padding_bottom_xs = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 2);
/// grid_spacer * 3
const padding_bottom_s = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 3);
/// grid_spacer * 4
const padding_bottom_m = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 4);
/// grid_spacer * 5
const padding_bottom_l = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 5);
/// grid_spacer * 6
const padding_bottom_xl = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 6);
/// grid_spacer * 7
const padding_bottom_xxl = EdgeInsets.fromLTRB(0, 0, 0, grid_spacer * 7);

// Paddings (Left)
const padding_top_left = EdgeInsets.only(left: 0);
/// grid_spacer  / 2
const padding_left_xxxs = EdgeInsets.fromLTRB(grid_spacer/2, 0, 0, 0);
/// grid_spacer * 1
const padding_left_xxs = EdgeInsets.fromLTRB(grid_spacer, 0, 0, 0);
/// grid_spacer * 2
const padding_left_xs = EdgeInsets.fromLTRB(grid_spacer * 2, 0, 0, 0);
/// grid_spacer * 3
const padding_left_s = EdgeInsets.fromLTRB(grid_spacer * 3, 0, 0, 0);
/// grid_spacer * 4
const padding_left_m = EdgeInsets.fromLTRB(grid_spacer * 4, 0, 0, 0);
/// grid_spacer * 5
const padding_left_l = EdgeInsets.fromLTRB(grid_spacer * 5, 0, 0, 0);
/// grid_spacer * 6
const padding_left_xl = EdgeInsets.fromLTRB(grid_spacer * 6, 0, 0, 0);
/// grid_spacer * 7
const padding_left_xxl = EdgeInsets.fromLTRB(grid_spacer * 7, 0, 0, 0);



// ---------------------------------
// Buttons
// ---------------------------------
const padding_button_s = EdgeInsets.symmetric(horizontal: grid_spacer * 2);
const padding_button_m = EdgeInsets.symmetric(horizontal: grid_spacer * 2);
const padding_button_l = EdgeInsets.symmetric(horizontal: grid_spacer * 2);