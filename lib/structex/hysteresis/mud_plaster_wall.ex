defmodule Structex.Hysteresis.MudPlasterWall do
  @moduledoc """
  The characteristic model of the mud plaster wall.

  This is according to 'A manual of aseismic design method for traditional wooden buildings
  including specific techniques for unfixing column bases to foundation stones (2019, The editorial
  committee of disign manual for traditional wooden buildings)'.

      iex> Structex.Hysteresis.equivalent_stiffness(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.9,
      ...>     inner_height: 2.6,
      ...>     inner_width: 0.805,
      ...>     thickness: 0.06
      ...>   },
      ...>   0.012
      ...> )
      112678.14008620691

      iex> Structex.Hysteresis.equivalent_stiffness(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.1,
      ...>     inner_height: 1.8,
      ...>     inner_width: 1.98,
      ...>     thickness: 0.06
      ...>   },
      ...>   0.049
      ...> )
      223295.51020408157

      iex> Structex.Hysteresis.equivalent_stiffness(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.9,
      ...>     inner_height: 2.6,
      ...>     inner_width: 0.805,
      ...>     thickness: 0.06
      ...>   },
      ...>   0
      ...> )
      120666.72413793104

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.9,
      ...>     inner_height: 2.6,
      ...>     inner_width: 0.805,
      ...>     thickness: 0.06
      ...>   },
      ...>   0.005
      ...> )
      0.0

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.9,
      ...>     inner_height: 2.6,
      ...>     inner_width: 0.805,
      ...>     thickness: 0.06,
      ...>     elastic_limit_distortion: 2.9 / 480
      ...>   },
      ...>   0.03
      ...> )
      0.03802034751639721

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.1,
      ...>     inner_height: 1.8,
      ...>     inner_width: 1.98,
      ...>     thickness: 0.06
      ...>   },
      ...>   0.05
      ...> )
      0.09974943526340882

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.9,
      ...>     inner_height: 2.6,
      ...>     inner_width: 0.805,
      ...>     thickness: 0.06
      ...>   },
      ...>   0
      ...> )
      0.0

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.MudPlasterWall{
      ...>     structural_height: 2.1,
      ...>     inner_height: 1.8,
      ...>     inner_width: 1.98,
      ...>     thickness: 0.06
      ...>   },
      ...>   0.015
      ...> )
      0.0
  """
  @typedoc """
  The struct representing the characteristic model which implements `Structex.Hysteresis` protocol.

  When `elastic_limit_distortion` is nil, it is considered to 1/120(rad) as default.
  """
  @type t :: %Structex.Hysteresis.MudPlasterWall{
          structural_height: number,
          inner_height: number,
          inner_width: number,
          thickness: number,
          elastic_limit_distortion: number | nil
        }
  defstruct [
    :structural_height,
    :inner_height,
    :inner_width,
    :thickness,
    :elastic_limit_distortion
  ]

  defimpl Structex.Hysteresis do
    defguardp is_positive(num) when is_number(num) and num > 0
    @spec efficient_width(number, number) :: number
    defp efficient_width(width, height) when height > width, do: width * width / height
    defp efficient_width(_, height), do: height
    @spec stress_limit_by_shear(number) :: number
    defp stress_limit_by_shear(angle) when angle >= 1 / 15 do
      max((angle - 1 / 15) / (1 / 10 - 1 / 15) * (34 - 58) + 58, 0)
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 20 do
      (angle - 1 / 20) / (1 / 15 - 1 / 20) * (58 - 72) + 72
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 30 do
      (angle - 1 / 30) / (1 / 20 - 1 / 30) * (72 - 84) + 84
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 45 do
      (angle - 1 / 45) / (1 / 30 - 1 / 45) * (84 - 93) + 93
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 60 do
      (angle - 1 / 60) / (1 / 45 - 1 / 60) * (93 - 98) + 98
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 90 do
      (angle - 1 / 90) / (1 / 60 - 1 / 90) * (98 - 96) + 96
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 120 do
      (angle - 1 / 120) / (1 / 90 - 1 / 120) * (96 - 86) + 86
    end

    defp stress_limit_by_shear(angle) when angle >= 1 / 240 do
      (angle - 1 / 240) / (1 / 120 - 1 / 240) * (86 - 54) + 54
    end

    defp stress_limit_by_shear(angle) do
      (angle - 1 / 480) / (1 / 240 - 1 / 480) * (54 - 30) + 30
    end

    @spec stress_limit_by_bending(number) :: number
    defp stress_limit_by_bending(angle) when angle >= 1 / 15 do
      max((angle - 1 / 15) / (1 / 10 - 1 / 15) * (32 - 52) + 52, 0)
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 20 do
      (angle - 1 / 20) / (1 / 15 - 1 / 20) * (52 - 60) + 60
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 30 do
      (angle - 1 / 30) / (1 / 20 - 1 / 30) * (60 - 65) + 65
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 45 do
      (angle - 1 / 45) / (1 / 30 - 1 / 45) * (65 - 68) + 68
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 60 do
      (angle - 1 / 60) / (1 / 45 - 1 / 60) * (68 - 70) + 70
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 90 do
      (angle - 1 / 90) / (1 / 60 - 1 / 90) * (70 - 60) + 60
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 120 do
      (angle - 1 / 120) / (1 / 90 - 1 / 120) * (60 - 48) + 48
    end

    defp stress_limit_by_bending(angle) when angle >= 1 / 240 do
      (angle - 1 / 240) / (1 / 120 - 1 / 240) * (48 - 28) + 28
    end

    defp stress_limit_by_bending(angle) do
      (angle - 1 / 480) / (1 / 240 - 1 / 480) * (28 - 15) + 15
    end

    def equivalent_stiffness(
          %Structex.Hysteresis.MudPlasterWall{
            structural_height: s_height,
            inner_height: height,
            inner_width: width,
            thickness: thickness
          },
          distortion
        )
        when is_positive(thickness) and is_positive(height) and is_positive(width) and
               is_positive(s_height) and is_number(distortion) and
               abs(distortion) / s_height <= 1 / 480 do
      min(30 * width, 15 * 3.25 * efficient_width(width, height)) * thickness * 4.8e5 / s_height
    end

    def equivalent_stiffness(
          %Structex.Hysteresis.MudPlasterWall{
            structural_height: s_height,
            inner_height: height,
            inner_width: width,
            thickness: thickness
          },
          distortion
        )
        when is_positive(s_height) and is_positive(thickness) and
               is_positive(height) and is_positive(width) and is_number(distortion) do
      angle = abs(distortion) / s_height

      thickness * 1000 / abs(distortion) *
        min(
          stress_limit_by_shear(angle) * width,
          stress_limit_by_bending(angle) * 3.25 * efficient_width(width, height)
        )
    end

    def equivalent_damping_ratio(
          %Structex.Hysteresis.MudPlasterWall{
            structural_height: s_height,
            inner_height: height,
            inner_width: width,
            thickness: thickness,
            elastic_limit_distortion: eld
          },
          distortion
        )
        when is_positive(s_height) and is_positive(height) and is_positive(width) and
               is_positive(thickness) and is_positive(eld) and is_number(distortion) and
               (abs(distortion) <= eld or abs(distortion) / s_height <= 1 / 480) do
      0.0
    end

    def equivalent_damping_ratio(
          %Structex.Hysteresis.MudPlasterWall{elastic_limit_distortion: eld} = hysteresis,
          distortion
        )
        when is_positive(eld) and is_number(distortion) do
      plasticity =
        equivalent_stiffness(hysteresis, distortion) / equivalent_stiffness(hysteresis, eld)

      (0.5 - 0.5 * plasticity) / :math.pi()
    end

    def equivalent_damping_ratio(
          %Structex.Hysteresis.MudPlasterWall{
            structural_height: s_height,
            elastic_limit_distortion: nil
          } = hysteresis,
          distortion
        ) do
      %{hysteresis | elastic_limit_distortion: s_height / 120}
      |> equivalent_damping_ratio(distortion)
    end
  end
end
