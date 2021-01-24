defmodule Structex.Model do
  @doc """
  Calculates the equivalent stiffness from a histeresis skeleton function and the maximum
  distortion.

      iex> Structex.Model.equivalent_stiffness(0.01, fn x -> 120 * x end)
      120.0

      iex> Structex.Model.equivalent_stiffness(0.1, fn _ -> 15 end)
      150.0
  """
  @spec equivalent_stiffness(number, (number -> number)) :: float
  def equivalent_stiffness(maximum_distortion, skeleton)
      when is_number(maximum_distortion) and is_function(skeleton, 1) do
    skeleton.(maximum_distortion) / maximum_distortion
  end

  @doc """
  Calculates the equivalent damping ratio from a histeresis skeleton function and the maximum
  distortion.

      iex> Structex.Model.equivalent_damping_ratio(0.1, fn _ -> 12 end, :peak_oriented)
      0.15915494309189535

      iex> Structex.Model.equivalent_damping_ratio(0.1, fn _ -> 12 end, :peak_oriented, unloading_stiffness: 120)
      0.0

      iex> Structex.Model.equivalent_damping_ratio(0.1, fn _ -> 12 end, :peak_oriented, unloading_stiffness: 150)
      0.03183098861837906

      iex> Structex.Model.equivalent_damping_ratio(0.1, fn _ -> 12 end, :peak_oriented, unloading_stiffness: 100)
      0.0
  """
  @spec equivalent_damping_ratio(number, (number -> number), :peak_oriented, keyword) :: float
  def equivalent_damping_ratio(maximum_distortion, skeleton, :peak_oriented, options \\ [])
      when is_number(maximum_distortion) and is_function(skeleton, 1) do
    case Keyword.fetch(options, :unloading_stiffness) do
      {:ok, unloading_stiffness} ->
        case equivalent_stiffness(maximum_distortion, skeleton) do
          stiffness when stiffness <= unloading_stiffness ->
            (0.5 - 0.5 * stiffness / unloading_stiffness) / :math.pi()

          _ ->
            0.0
        end

      :error ->
        0.5 / :math.pi()
    end
  end
end
