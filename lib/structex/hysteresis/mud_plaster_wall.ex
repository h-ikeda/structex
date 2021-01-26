defmodule Structex.Hysteresis.MudPlasterWall do
  @moduledoc """
  The structural characteristic of the mud plaster wall.

  This is according to 'A manual of aseismic design method for traditional wooden buildings
  including specific techniques for unfixing column bases to foundation stones (2019, The editorial
  committee of disign manual for traditional wooden buildings)'.
  """
  @doc """
  Returns a `t:Structex.Hysteresis.t/0` struct representing the specific mud plaster wall.
  """
  @spec new(number, number, number, number) :: Structex.Hysteresis.t()
  def new(structural_height, inner_height, inner_width, thickness)
      when is_number(structural_height) and structural_height > 0 and
             is_number(inner_height) and inner_height > 0 and
             is_number(inner_width) and inner_width > 0 and
             is_number(thickness) and thickness > 0 do
    ratio =
      (inner_height > inner_width and inner_width * inner_width / inner_height) || inner_height

    skeleton = fn distortion ->
      shear_stress =
        case abs(distortion) / structural_height do
          d when d >= 1 / 15 ->
            dx = (d - 1 / 15) / (1 / 10 - 1 / 15)

            min(inner_width * (dx * (34 - 58) + 58), (dx * (32 - 52) + 52) * 3.25 * ratio)
            |> max(0.0)

          d when d >= 1 / 20 ->
            dx = (d - 1 / 20) / (1 / 15 - 1 / 20)
            min(inner_width * (dx * (58 - 72) + 72), (dx * (52 - 60) + 60) * 3.25 * ratio)

          d when d >= 1 / 30 ->
            dx = (d - 1 / 30) / (1 / 20 - 1 / 30)
            min(inner_width * (dx * (72 - 84) + 84), (dx * (60 - 65) + 65) * 3.25 * ratio)

          d when d >= 1 / 45 ->
            dx = (d - 1 / 45) / (1 / 30 - 1 / 45)
            min(inner_width * (dx * (84 - 93) + 93), (dx * (65 - 68) + 68) * 3.25 * ratio)

          d when d >= 1 / 60 ->
            dx = (d - 1 / 60) / (1 / 45 - 1 / 60)
            min(inner_width * (dx * (93 - 98) + 98), (dx * (68 - 70) + 70) * 3.25 * ratio)

          d when d >= 1 / 90 ->
            dx = (d - 1 / 90) / (1 / 60 - 1 / 90)
            min(inner_width * (dx * (98 - 96) + 96), (dx * (70 - 60) + 60) * 3.25 * ratio)

          d when d >= 1 / 120 ->
            dx = (d - 1 / 120) / (1 / 90 - 1 / 120)
            min(inner_width * (dx * (96 - 86) + 86), (dx * (60 - 48) + 48) * 3.25 * ratio)

          d when d >= 1 / 240 ->
            dx = (d - 1 / 240) / (1 / 120 - 1 / 240)
            min(inner_width * (dx * (86 - 54) + 54), (dx * (48 - 28) + 28) * 3.25 * ratio)

          d when d >= 1 / 480 ->
            dx = (d - 1 / 480) / (1 / 240 - 1 / 480)
            min(inner_width * (dx * (54 - 30) + 30), (dx * (28 - 15) + 15) * 3.25 * ratio)

          d ->
            min(inner_width * d / (1 / 480) * 30, d / (1 / 480) * 15 * 3.25 * ratio)
        end

      ((distortion < 0 and -shear_stress) || shear_stress) * thickness * 1000
    end

    stiffness =
      min(inner_width * 480 * 30, 480 * 15 * 3.25 * ratio) * thickness / structural_height * 1000

    %Structex.Hysteresis{
      skeleton: skeleton,
      initial_stiffness: stiffness,
      unloading_stiffness: stiffness,
      model: :peak_oriented
    }
  end
end
