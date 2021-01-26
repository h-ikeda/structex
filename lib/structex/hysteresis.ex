defmodule Structex.Hysteresis do
  alias Structex.Hysteresis

  @type t :: %Hysteresis{
          skeleton: (number -> number),
          initial_stiffness: number,
          unloading_stiffness: number,
          model: :peak_oriented
        }
  defstruct [:skeleton, :initial_stiffness, :unloading_stiffness, :model]

  @doc """
  Calculates the equivalent stiffness from a histeresis skeleton function and the maximum
  distortion.

      iex> Structex.Hysteresis.equivalent_stiffness(0.012, Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 0.805, 0.06))
      112678.14008620691

      iex> Structex.Hysteresis.equivalent_stiffness(0.049, Structex.Hysteresis.MudPlasterWall.new(2.1, 1.8, 1.98, 0.06))
      223295.51020408157

      iex> Structex.Hysteresis.equivalent_stiffness(0.0, Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 0.805, 0.06))
      120666.72413793103
  """
  @spec equivalent_stiffness(number, t) :: number
  def equivalent_stiffness(maximum_distortion, %Hysteresis{initial_stiffness: stiffness})
      when maximum_distortion == 0 do
    stiffness
  end

  def equivalent_stiffness(maximum_distortion, %Hysteresis{skeleton: skeleton})
      when is_number(maximum_distortion) do
    skeleton.(maximum_distortion) / maximum_distortion
  end

  @doc """
  Calculates the equivalent damping ratio from a hysteresis model and the maximum distortion.

      iex> Structex.Hysteresis.equivalent_damping_ratio(0.005, Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 0.805, 0.06))
      0.0

      iex> Structex.Hysteresis.equivalent_damping_ratio(0.03, Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 0.805, 0.06))
      0.03802034751639719

      iex> Structex.Hysteresis.equivalent_damping_ratio(0.05, Structex.Hysteresis.MudPlasterWall.new(2.1, 1.8, 1.98, 0.06))
      0.11658099581481332

      iex> hysteresis = Structex.Hysteresis.MudPlasterWall.new(2.1, 1.8, 1.98, 0.06)
      ...> Structex.Hysteresis.equivalent_damping_ratio(0.05, %{hysteresis | unloading_stiffness: Structex.Hysteresis.equivalent_stiffness(2.1 / 120, hysteresis)})
      0.0997494352634088

      iex> Structex.Hysteresis.equivalent_damping_ratio(0.0, Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 0.805, 0.06))
      0.0

      iex> hysteresis = Structex.Hysteresis.MudPlasterWall.new(2.1, 1.8, 1.98, 0.06)
      ...> Structex.Hysteresis.equivalent_damping_ratio(0.015, %{hysteresis | unloading_stiffness: Structex.Hysteresis.equivalent_stiffness(2.1 / 120, hysteresis)})
      0.0
  """
  @spec equivalent_damping_ratio(number, t) :: float
  def equivalent_damping_ratio(maximum_distortion, %Hysteresis{}) when maximum_distortion == 0 do
    0.0
  end

  def equivalent_damping_ratio(
        maximum_distortion,
        %Hysteresis{model: :peak_oriented, unloading_stiffness: unloading_stiffness} = hysteresis
      )
      when is_number(maximum_distortion) do
    case equivalent_stiffness(maximum_distortion, hysteresis) do
      stiffness when stiffness < unloading_stiffness ->
        (0.5 - 0.5 * stiffness / unloading_stiffness) / :math.pi()

      _ ->
        0.0
    end
  end
end
