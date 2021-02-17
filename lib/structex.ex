defmodule Structex do
  @moduledoc """
  ## Calculation of response and limit strength

      iex> matrix =
      ...>   Structex.Tensor.new(2)
      ...>   |> Structex.Tensor.put_key(:ground, [:fixed])
      ...>   |> Structex.Tensor.put_key(:second_floor, [:free])
      ...>   |> Structex.Tensor.put_key(:roof, [:free])
      ...>
      ...> vector =
      ...>   Structex.Tensor.new(1)
      ...>   |> Structex.Tensor.put_key(:ground, [:fixed])
      ...>   |> Structex.Tensor.put_key(:second_floor, [:free])
      ...>   |> Structex.Tensor.put_key(:roof, [:free])
      ...>
      ...> mass =
      ...>   matrix
      ...>   |> put_in(
      ...>     [[:second_floor, :second_floor]],
      ...>     Tensorex.kronecker_delta(1) |> Tensorex.Operator.multiply(20.4)
      ...>   )
      ...>   |> put_in(
      ...>     [[:roof, :roof]],
      ...>     Tensorex.kronecker_delta(1) |> Tensorex.Operator.multiply(10.2)
      ...>   )
      ...>   |> Structex.Tensor.assembled()
      ...>
      ...> elements =
      ...>   List.duplicate({[:ground, :second_floor], %Structex.Element.Spring{constant: } Structex.Hysteresis.MudPlasterWall.new(2.7, 2.4, 1.7, 0.06)}, 9) ++
      ...>     List.duplicate({[:ground, :second_floor], Structex.Hysteresis.MudPlasterWall.new(2.7, 2.4, 1.23, 0.055)}, 7) ++
      ...>     List.duplicate({[:second_floor, :roof], Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 1.7, 0.06)}, 5) ++
      ...>     List.duplicate({[:second_floor, :roof], Structex.Hysteresis.MudPlasterWall.new(2.9, 2.6, 1.23, 0.055)}, 4)
      ...>
      ...> equivalent_linear_model =
      ...>   fn distortion ->
      ...>     d = Structex.Tensor.put_assembled(vector, distortion)
      ...>
      ...>     stiffness =
      ...>       hysteresis
      ...>       |> Stream.map(fn {[index1, index2] = index, model} ->
      ...>         diff = d[[index2]] |> Tensorex.Operator.subtract(d[[index1]])
      ...>         Structex.Element.equivalent_stiffness(model, index, diff)
      ...>       end)
      ...>       |> Enum.reduce(matrix, fn tensor, acc ->
      ...>         Structex.Tensor.merge(acc, &Tensorex.Operator.add(&1, tensor))
      ...>       end)
      ...>       |> Structex.Tensor.assembled()
      ...>
      ...>     {%Tensorex{shape: [degrees | _]} = natural_angular_frequencies, normal_mode_vectors} =
      ...>       Structex.Modal.normal_modes(mass, stiffness)
      ...>
      ...>     {natural_angular_frequency, mode_index} =
      ...>       0..(degrees - 1)
      ...>       |> Stream.map(&{natural_angular_frequencies[[&1, &1]], &1})
      ...>       |> Enum.min_by(&elem(&1, 0))
      ...>
      ...>     damping_ratio1 =
      ...>       Structex.Modal.strain_energy_propotional_damping(dx1)
      ...>       Structex.Model.equivalent_damping_ratio(
      ...>         dx1,
      ...>         skeleton1
      ...>       )
      ...>
      ...>     damping_ratio2 =
      ...>       Structex.Model.equivalent_damping_ratio(
      ...>         dx2,
      ...>         skeleton2
      ...>       )
      ...>
      ...>     damping_ratio = 0.2
      ...>
      ...>     damping =
      ...>       Structex.Modal.stiffness_propotional_damping(
      ...>         stiffness,
      ...>         natural_angular_frequency,
      ...>         damping_ratio
      ...>       )
      ...>
      ...>     {mass, damping, stiffness}
      ...>   end
      ...>
      ...> acceleration_response_spectrum =
      ...>   Stream.iterate(0.05, &(&1 * 1.1))
      ...>   |> Stream.take_while(&(&1 <= 8))
      ...>   |> Enum.map(fn natural_period ->
      ...>     {
      ...>       natural_period,
      ...>       Structex.Load.Seismic.standard_maximum_acceleration(137.166296, 34.910602, 250) *
      ...>         Structex.Load.Seismic.normalized_acceleration_response_spectrum(2.5, 0.16, 0.64).(natural_period)
      ...>     }
      ...>   end)
      ...>   |> Structex.Load.Seismic.reverse_convert_spectrum(0.5, 20, 0.05)
      ...>   |> Enum.map(fn {angular_frequency, ga0} ->
      ...>     hgs = Structex.Load.Seismic.squared_soil_amplification(angular_frequency, 0.56, 0.05, 0.2)
      ...>     {angular_frequency, hgs * ga0}
      ...>   end)
      ...>   |> Structex.Load.Seismic.convert_spectrum(0.5, 20, 3)
      ...>
      ...> response =
      ...>   Structex.limit_strength_response(
      ...>     equivalent_linear_model,
      ...>     Structex.Tensor.assebled(vector),
      ...>     acceleration_response_spectrum,
      ...>     :srss
      ...>   )
      ...>
      ...> [:ground, :second_floor, :roof]
      ...> |> Enum.map(&{&1, Structex.Tensor.put_assembled(vector, response)[[&1]]})
      [
        ground:       %Tensorex{data: %{},         shape: [1]},
        second_floor: %Tensorex{data: [0] => 0.0}, shape: [1]},
        roof:         %Tensorex{data: [0] => 0.0}, shape: [1]}
      ]
  """
  @doc """
  Calculates expected distortion response by equivalent linearization.

      iex> model =
      ...>   fn %Tensorex{shape: [2]} = distortion ->
      ...>     mass = Tensorex.from_list([[10.2, 0], [0, 20.4]])
      ...>     k0 = 88.1 - distortion[[0]] * 10
      ...>     k1 = 165.2 - distortion[[1]] * 15
      ...>     stiffness = Tensorex.from_list([[k0, -k0], [-k0, k0 + k1]])
      ...>     {eigens, _} = Structex.Modal.normal_modes(mass, stiffness)
      ...>     damping_ratio = 0.05 + distortion[[0]] * 0.05
      ...>     damping = Structex.Modal.stiffness_propotional_damping(stiffness, min(eigens[[0, 0]], eigens[[1, 1]]), damping_ratio)
      ...>     {mass, damping, stiffness}
      ...>   end
      ...>
      ...> response_spectrum =
      ...>   fn natural_period, damping_ratio ->
      ...>     fh = 1.5 / (1 + 10 * damping_ratio)
      ...>     Structex.Load.Seismic.normalized_acceleration_response_spectrum(3.2 * 1.5, 0.16, 0.64).(natural_period) * fh
      ...>   end
      ...>
      ...> Structex.limit_strength_response(model, Tensorex.from_list([0, 0]), response_spectrum, :cqc)
      %Tensorex{data: %{[0] => 0.2894516267339246, [1] => 0.15860082111575682}, shape: [2]}
  """
  @spec limit_strength_response(
          (distortion :: Tensorex.t() ->
             {mass :: Tensorex.t(), damping :: Tensorex.t(), stiffness :: Tensorex.t()}),
          Tensorex.t(),
          (natural_period :: number, damping_ratio :: number -> number),
          :srss | :cqc,
          number
        ) :: Tensorex.t()
  def limit_strength_response(
        model,
        %Tensorex{shape: [_]} = initial_distortion,
        acceleration_spectrum,
        superimpose_method,
        tolerance \\ 1.0e-15
      )
      when is_function(model, 1) and is_function(acceleration_spectrum, 2) and
             superimpose_method in [:srss, :cqc] do
    {
      %Tensorex{shape: [degrees, degrees]} = mass,
      %Tensorex{shape: [degrees, degrees]} = damping,
      %Tensorex{shape: [degrees, degrees]} = stiffness
    } = model.(initial_distortion)

    response =
      Structex.Modal.linear_modal_response(
        mass,
        damping,
        stiffness,
        mass |> Tensorex.Operator.multiply(Tensorex.fill([degrees], 1), [{1, 0}]),
        acceleration_spectrum,
        superimpose_method
      )

    if Tensorex.in_tolerance?(initial_distortion, response, tolerance) do
      response
    else
      limit_strength_response(model, response, acceleration_spectrum, superimpose_method)
    end
  end

  @doc """
  The standard acceleration due to gravity on the surface of the earth.
  """
  @spec standard_gravity_acceleration() :: float
  def standard_gravity_acceleration(), do: 9.80665
end
