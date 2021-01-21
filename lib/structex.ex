defmodule Structex do
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
          :srss | :cqc
        ) :: Tensorex.t()
  def limit_strength_response(
        model,
        %Tensorex{shape: [_]} = initial_distortion,
        acceleration_spectrum,
        superimpose_method
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

    if initial_distortion == response do
      response
    else
      limit_strength_response(model, response, acceleration_spectrum, superimpose_method)
    end
  end
end
