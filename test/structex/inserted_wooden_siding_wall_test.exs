defmodule Structex.InsertedWoodenSidingWallTest do
  use ExUnit.Case, async: true
  alias Structex.InsertedWoodenSidingWall
  doctest InsertedWoodenSidingWall

  test "first_slip_deformation_angle/4" do
    assert_in_delta InsertedWoodenSidingWall.first_slip_deformation_angle(1745, 2700, 0, 1),
                    0.000572959779263504,
                    1.0e-18

    assert_in_delta InsertedWoodenSidingWall.first_slip_deformation_angle(270.0, 174.5, 0.1, 0),
                    0.000572959779263504,
                    1.0e-18

    assert_in_delta InsertedWoodenSidingWall.first_slip_deformation_angle(
                      0.835,
                      2.7,
                      0.001,
                      0.003
                    ),
                    0.00396096695497893,
                    1.0e-17

    assert InsertedWoodenSidingWall.first_slip_deformation_angle(174.5, 270, 0, 0) === 0.0
  end

  test "shear_connecter_inverted_rigidity_with_friction/6" do
    assert_in_delta InsertedWoodenSidingWall.shear_connecter_inverted_rigidity_with_friction(
                      11,
                      5,
                      13.5,
                      270,
                      174.5,
                      0.4
                    ),
                    0.00048758839589785097,
                    1.0e-18

    assert_in_delta InsertedWoodenSidingWall.shear_connecter_inverted_rigidity_with_friction(
                      0.11,
                      5,
                      0.135,
                      2.7,
                      1.745,
                      0.4
                    ),
                    4.87588395897851,
                    1.0e-14

    assert_in_delta InsertedWoodenSidingWall.shear_connecter_inverted_rigidity_with_friction(
                      11,
                      5,
                      13.5,
                      270,
                      174.5,
                      0
                    ),
                    0.0012794612794612794,
                    1.0e-17

    assert InsertedWoodenSidingWall.shear_connecter_inverted_rigidity_with_friction(
             11,
             5,
             13.5,
             270,
             74.5,
             0.4
           ) === 0.0
  end

  test "siding_inverted_rigidity/3" do
    assert_in_delta InsertedWoodenSidingWall.siding_inverted_rigidity(45.73, 2.7, 174.5),
                    0.00004641299597304602,
                    1.0e-19
  end

  test "diagonal_siding_zone_inverted_rigidity/4" do
    assert_in_delta InsertedWoodenSidingWall.diagonal_siding_zone_inverted_rigidity(
                      686,
                      50,
                      2.7,
                      174.5,
                      270
                    ),
                    0.001154874879926913,
                    1.0e-17
  end

  test "column_side_inverted_rigidity/7" do
    assert_in_delta InsertedWoodenSidingWall.column_side_inverted_rigidity(
                      13.72,
                      10.5,
                      10.5,
                      5,
                      2.7,
                      13.5,
                      270
                    ),
                    0.00015764926940813528,
                    1.0e-18
  end

  test "column_side_inverted_rigidity_with_shear_connecters/11" do
    assert_in_delta InsertedWoodenSidingWall.column_side_inverted_rigidity_with_shear_connecters(
                      13.72,
                      10.5,
                      10.5,
                      5,
                      2.7,
                      13.5,
                      270,
                      174.5,
                      5,
                      11,
                      0
                    ),
                    0.00007263116381443908,
                    1.0e-19

    assert_in_delta InsertedWoodenSidingWall.column_side_inverted_rigidity_with_shear_connecters(
                      13.72,
                      10.5,
                      10.5,
                      5,
                      2.7,
                      13.5,
                      270,
                      174.5,
                      5,
                      11,
                      0.4
                    ),
                    0.000027678924892035516,
                    1.0e-19
  end

  test "beam_side_inverted_rigidity/7" do
    assert_in_delta InsertedWoodenSidingWall.beam_side_inverted_rigidity(
                      13.72,
                      10.5,
                      10.5,
                      5,
                      2.7,
                      174.5,
                      270
                    ),
                    0.00011262445165832249,
                    1.0e-18
  end

  test "inverted_rigidity/" do
    assert_in_delta InsertedWoodenSidingWall.inverted_rigidity(
                      shear_connecter_rigidity: 11,
                      number_of_shear_connecters: 5,
                      siding_width: 13.5,
                      frame_inner_height: 270,
                      frame_inner_width: 174.5,
                      friction_coefficient: 0,
                      shear_modulus: 45.73,
                      siding_thickness: 2.7,
                      siding_fiber_direction_elasticity: 686,
                      elasticity_ratio: 50,
                      column_fiber_orthogonal_direction_elasticity: 13.72,
                      beam_fiber_orthogonal_direction_elasticity: 13.72,
                      column_depth: 10.5,
                      beam_height: 10.5,
                      column_width: 10.5,
                      beam_width: 10.5,
                      column_substitution_coefficient: 5,
                      beam_substitution_coefficient: 5,
                      shear_connecters_between_beams_and_sidings: false
                    ),
                    0.0027510228764276966,
                    1.0e-17

    assert_in_delta InsertedWoodenSidingWall.inverted_rigidity(
                      shear_connecter_rigidity: 11,
                      number_of_shear_connecters: 5,
                      siding_width: 13.5,
                      frame_inner_height: 270,
                      frame_inner_width: 174.5,
                      friction_coefficient: 0,
                      shear_modulus: 45.73,
                      siding_thickness: 2.7,
                      siding_fiber_direction_elasticity: 686,
                      elasticity_ratio: 50,
                      column_fiber_orthogonal_direction_elasticity: 13.72,
                      beam_fiber_orthogonal_direction_elasticity: 13.72,
                      column_depth: 10.5,
                      beam_height: 10.5,
                      column_width: 10.5,
                      beam_width: 10.5,
                      column_substitution_coefficient: 5,
                      beam_substitution_coefficient: 5,
                      shear_connecters_between_beams_and_sidings: true
                    ),
                    0.0026660047708340004,
                    1.0e-17

    assert_in_delta InsertedWoodenSidingWall.inverted_rigidity(
                      shear_connecter_rigidity: 11,
                      number_of_shear_connecters: 5,
                      siding_width: 13.5,
                      frame_inner_height: 270,
                      frame_inner_width: 174.5,
                      friction_coefficient: 0.4,
                      shear_modulus: 45.73,
                      siding_thickness: 2.7,
                      siding_fiber_direction_elasticity: 686,
                      elasticity_ratio: 50,
                      column_fiber_orthogonal_direction_elasticity: 13.72,
                      beam_fiber_orthogonal_direction_elasticity: 13.72,
                      column_depth: 10.5,
                      beam_height: 10.5,
                      column_width: 10.5,
                      beam_width: 10.5,
                      column_substitution_coefficient: 5,
                      beam_substitution_coefficient: 5,
                      shear_connecters_between_beams_and_sidings: true
                    ),
                    0.0018291796483481683,
                    1.0e-17
  end

  test "shear_connecter_yield_resistance/5" do
    assert_in_delta InsertedWoodenSidingWall.shear_connecter_yield_resistance(
                      5,
                      3.38,
                      174.5,
                      270,
                      0.4
                    ),
                    44.34661654135338,
                    1.0e-13

    assert_in_delta InsertedWoodenSidingWall.shear_connecter_yield_resistance(
                      5,
                      3.38,
                      91,
                      240.5,
                      0
                    ),
                    16.9,
                    1.0e-13
  end

  test "diagonal_siding_zone_yield_resistance/6" do
    assert_in_delta InsertedWoodenSidingWall.diagonal_siding_zone_yield_resistance(
                      2.147,
                      0.2984,
                      2.7,
                      174.5,
                      270,
                      0.05
                    ),
                    20.6612520784784,
                    1.0e-13
  end

  test "yield_resistance/1" do
    assert_in_delta InsertedWoodenSidingWall.yield_resistance(
                      number_of_shear_connecters: 5,
                      single_connecter_yield_resistance: 3.38,
                      fiber_direction_compressive_strength: 2.147,
                      fiber_orthogonal_direction_compressive_strength: 0.2984,
                      thickness: 2.7,
                      frame_inner_width: 174.5,
                      frame_inner_height: 270
                    ),
                    16.9,
                    1.0e-13

    assert_in_delta InsertedWoodenSidingWall.yield_resistance(
                      number_of_shear_connecters: 5,
                      single_connecter_yield_resistance: 3.38,
                      fiber_direction_compressive_strength: 2.147,
                      fiber_orthogonal_direction_compressive_strength: 0.2984,
                      thickness: 2.7,
                      frame_inner_width: 174.5,
                      frame_inner_height: 270,
                      friction_coefficient: 0.4
                    ),
                    20.6612520784784,
                    1.0e-13
  end
end
