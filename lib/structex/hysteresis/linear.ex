defmodule Structex.Hysteresis.Linear do
  @moduledoc """
  The completely linear elastic model.

      iex> Structex.Hysteresis.equivalent_stiffness(
      ...>   %Structex.Hysteresis.Linear{constant: 120900.8},
      ...>   0.012
      ...> )
      120900.8

      iex> Structex.Hysteresis.equivalent_stiffness(
      ...>   %Structex.Hysteresis.Linear{constant: 120900.8},
      ...>   0.0
      ...> )
      120900.8

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.Linear{constant: 120900.8},
      ...>   0.08
      ...> )
      0.0

      iex> Structex.Hysteresis.equivalent_damping_ratio(
      ...>   %Structex.Hysteresis.Linear{constant: 120900.8},
      ...>   0.0
      ...> )
      0.0
  """
  @type t :: %Structex.Hysteresis.Linear{constant: number}
  defstruct [:constant]

  defimpl Structex.Hysteresis do
    def equivalent_stiffness(%Structex.Hysteresis.Linear{constant: constant}, distortion)
        when is_number(constant) and constant >= 0 and is_number(distortion) do
      constant
    end

    def equivalent_damping_ratio(%Structex.Hysteresis.Linear{constant: constant}, distortion)
        when is_number(constant) and constant >= 0 and is_number(distortion) do
      0.0
    end
  end
end
