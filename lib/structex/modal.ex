defmodule Structex.Modal do
  @moduledoc """
  Functions related to modal analysis.
  """
  @doc """
  Returns a tensor where each diagonal element is natural angular frequency and a corresponding
  normal mode matrix.

      iex> Structex.Modal.normal_modes(
      ...>   Tensorex.from_list([[   15.3,     0  ],
      ...>                       [    0  ,    10.7]]),
      ...>   Tensorex.from_list([[ 8491  , -2726  ],
      ...>                       [-2726  ,  2726  ]]))
      {
        %Tensorex{data: %{[0, 0] => 25.796997183256615 ,
                                                         [1, 1] => 12.010354354833797  }, shape: [2, 2]},
        %Tensorex{data: %{[0, 0] =>  0.8497907788067889, [0, 1] =>  0.39796814317351187,
                          [1, 0] => -0.5271201307623825, [1, 1] =>  0.9173992353490529 }, shape: [2, 2]}
      }
  """
  @spec normal_modes(Tensorex.t(), Tensorex.t()) :: {Tensorex.t(), Tensorex.t()}
  def normal_modes(
        %Tensorex{shape: [degrees, degrees]} = mass,
        %Tensorex{shape: [degrees, degrees]} = stiffness
      ) do
    {eigenvalues, eigenvectors} =
      Tensorex.Analyzer.solve(mass, stiffness) |> Tensorex.Analyzer.eigen_decomposition()

    {Tensorex.map(eigenvalues, &:math.sqrt/1), eigenvectors}
  end

  @doc """
  Returns a vector of participation factors.

      iex> Structex.Modal.participation_factors(Tensorex.from_list([[ 0.8497907788067889,  0.39796814317351187],
      ...>                                                          [-0.5271201307623825,  0.9173992353490529 ]]),
      ...>                                      Tensorex.from_list([[15.3               ,  0                  ],
      ...>                                                          [ 0                 , 10.7                ]]),
      ...>                                      Tensorex.from_list([15.3, 10.7]))
      %Tensorex{data: %{[0] => 0.5250096184416861, [1] => 1.3916984988969536}, shape: [2]}
  """
  @spec participation_factors(Tensorex.t(), Tensorex.t(), Tensorex.t()) :: Tensorex.t()
  def participation_factors(
        %Tensorex{shape: [degrees, degrees]} = eigenvectors,
        %Tensorex{shape: [degrees, degrees]} = mass,
        %Tensorex{shape: [degrees]} = force_amplification
      ) do
    Tensorex.Analyzer.solve(
      eigenvectors
      |> Tensorex.Operator.multiply(mass, [{0, 0}])
      |> Tensorex.Operator.multiply(eigenvectors, [{1, 0}]),
      eigenvectors
      |> Tensorex.Operator.multiply(force_amplification, [{0, 0}])
    )
  end

  @doc """
  Superimposes modal responses.

  To calculate the exact solution, pass a vector where each element is the solution of
  corresponding 1-degree motion equation and the normal mode matrix:

      iex> Structex.Modal.superimpose(Tensorex.from_list([2.5, 1.3, 3.2]), :direct,
      ...>                            Tensorex.from_list([[0.423333756667,  0.727392967453 , 0.558145572185],
      ...>                                                [0.550333883667, -0.363696483726, -0.558145572185],
      ...>                                                [0.719667386334, -0.581914373962,  0.613960129404]]))
      %Tensorex{data: %{[0] =>  3.7900110803484006,
                        [1] => -0.8830365506683002,
                        [2] =>  3.0073521937772   }, shape: [3]}

  A common use case of direct superimposing is time history response analysis. We can know the
  exact response at any particular time.

  To estimate maximum response by SRSS (square root of the sum of the squares), pass a vector where
  each element is the maximum response of 1-degree vibration model and the normal mode matrix:

      iex> Structex.Modal.superimpose(Tensorex.from_list([2.5, 1.3, 3.2]), :srss,
      ...>                            Tensorex.from_list([[0.423333756667,  0.727392967453 , 0.558145572185],
      ...>                                                [0.550333883667, -0.363696483726, -0.558145572185],
      ...>                                                [0.719667386334, -0.581914373962,  0.613960129404]]))
      %Tensorex{data: %{[0] => 2.2812897079070202,
                        [1] => 2.3035835719876396,
                        [2] => 2.7693356595808605}, shape: [3]}

  A common use case of SRSS superimposing is getting maximum response of lumped mass model, because
  usually their natural periods are appropriately away from each other.

  To estimate maximum response by CQC (complete quadratic combination), pass a vector where
  each element is the maximum response of 1-degree vibration model, the normal mode matrix and the
  mode correlation coefficient matrix:

      iex> Structex.Modal.superimpose(Tensorex.from_list([2.5, 1.3, 3.2]), :cqc,
      ...>                            Tensorex.from_list([[0.423333756667,  0.727392967453 , 0.558145572185],
      ...>                                                [0.550333883667, -0.363696483726, -0.558145572185],
      ...>                                                [0.719667386334, -0.581914373962,  0.613960129404]]),
      ...>                            Tensorex.from_list([[1  , 0.5, 0.05],
      ...>                                                [0.4, 1  , 0.2 ],
      ...>                                                [0.1, 0.2, 1   ]]))
      %Tensorex{data: %{[0] => 2.657834740006921 ,
                        [1] => 2.165693955620106 ,
                        [2] => 2.5258642049998965}, shape: [3]}

  A common use case of CQC superimposing is getting maximum response of 3D model, because they
  usually have close natural periods. In this case, SRSS estimates maximum response too less.
  """
  @spec superimpose(Tensorex.t(), :direct | :srss, Tensorex.t()) :: Tensorex.t()
  def superimpose(
        %Tensorex{shape: [degrees]} = modal_response,
        :direct,
        %Tensorex{shape: [degrees, degrees]} = normal_mode_vectors
      ) do
    normal_mode_vectors |> Tensorex.Operator.multiply(modal_response, [{1, 0}])
  end

  def superimpose(
        %Tensorex{shape: [degrees]} = modal_response,
        :srss,
        %Tensorex{shape: [rows, degrees]} = normal_mode_vectors
      ) do
    modal_responses =
      Enum.reduce(0..(degrees - 1), normal_mode_vectors, fn degree, acc ->
        update_in(acc[[0..-1, degree]], &Tensorex.Operator.multiply(&1, modal_response[[degree]]))
      end)

    Tensorex.map(Tensorex.zero([rows]), fn _, index ->
      row = modal_responses[index]
      row |> Tensorex.Operator.multiply(row, [{0, 0}]) |> :math.sqrt()
    end)
  end

  @doc """
  Superimposes modal responses.

  See `superimpose/3` for details.
  """
  @spec superimpose(Tensorex.t(), :cqc, Tensorex.t(), Tensorex.t()) :: Tensorex.t()
  def superimpose(
        %Tensorex{shape: [degrees]} = modal_response,
        :cqc,
        %Tensorex{shape: [rows, degrees]} = normal_mode_vectors,
        %Tensorex{shape: [degrees, degrees]} = mode_correlation_coefficients
      ) do
    modal_responses =
      Enum.reduce(0..(degrees - 1), normal_mode_vectors, fn degree, acc ->
        update_in(acc[[0..-1, degree]], &Tensorex.Operator.multiply(&1, modal_response[[degree]]))
      end)

    Tensorex.map(Tensorex.zero([rows]), fn _, index ->
      row = modal_responses[index]

      row
      |> Tensorex.Operator.multiply(mode_correlation_coefficients, [{0, 0}])
      |> Tensorex.Operator.multiply(row, [{0, 0}])
      |> :math.sqrt()
    end)
  end

  @doc """
  Generates a mode correlation coefficient matrix from an enumerable of tuples of natural period
  and damping factor.

      iex> Structex.Modal.mode_correlation_coefficients(Tensorex.from_list([[0.3 , 0   ],
      ...>                                                                  [0   , 1   ]]),
      ...>                                              Tensorex.from_list([[0.05, 0   ],
      ...>                                                                  [0   , 0.11]]))
      %Tensorex{data: %{[0, 0] => 1                , [0, 1] => 0.016104174049193782,
                        [1, 0] => 0.143086511954331, [1, 1] => 1                   }, shape: [2, 2]}
  """
  @spec mode_correlation_coefficients(Tensorex.t(), Tensorex.t()) :: Tensorex.t()
  def mode_correlation_coefficients(
        %Tensorex{shape: [degrees, degrees]} = natural_frequencies,
        %Tensorex{shape: [degrees, degrees]} = damping_factors
      ) do
    Tensorex.map(damping_factors, fn
      _, [j, j] ->
        1

      _, [j, k] ->
        r = natural_frequencies[[j, j]] / natural_frequencies[[k, k]]
        hj = damping_factors[[j, j]]
        hk = damping_factors[[k, k]]

        2 * :math.sqrt(hj * hk * r * r * r) * (hj + r * hk) /
          ((((hk * r + hj) * hj + hk * hk + 0.25) * r + hj * hk - 0.5) * r + 0.25)
    end)
  end

  @doc """
  Calculates the maximum response distortion of the vibration model from the acceleration spectrum.

      iex> Structex.Modal.linear_modal_response(Tensorex.from_list([[   20.4,     0  ],
      ...>                                                          [    0  ,    10.2]]),
      ...>                                      Tensorex.from_list([[  302.408,  -244.747],
      ...>                                                          [ -244.747,   244.747]]),
      ...>                                      Tensorex.from_list([[ 4332  , -3506  ],
      ...>                                                          [-3506  ,  3506  ]]),
      ...>                                      Tensorex.from_list([20.4, 10.2]),
      ...>                                      fn t, h -> 1.024 / t * 2.025 * 1.5 / (1 + 10 * h) * 0.85 end,
      ...>                                      :cqc)
      %Tensorex{data: %{[0] => 0.028620536343935302,
                        [1] => 0.03094604399656699 }, shape: [2]}

      iex> Structex.Modal.linear_modal_response(Tensorex.from_list([[   20.4,     0  ],
      ...>                                                          [    0  ,    10.2]]),
      ...>                                      Tensorex.from_list([[  302.408,  -244.747],
      ...>                                                          [ -244.747,   244.747]]),
      ...>                                      Tensorex.from_list([[ 4332  , -3506  ],
      ...>                                                          [-3506  ,  3506  ]]),
      ...>                                      Tensorex.from_list([20.4, 10.2]),
      ...>                                      fn t, h -> 1.024 / t * 2.025 * 1.5 / (1 + 10 * h) * 0.85 end,
      ...>                                      :srss)
      %Tensorex{data: %{[0] => 0.028605899694462523,
                        [1] => 0.030973098740797646}, shape: [2]}
  """
  @spec linear_modal_response(
          Tensorex.t(),
          Tensorex.t(),
          Tensorex.t(),
          Tensorex.t(),
          (number, number -> number),
          :srss | :cqc
        ) :: Tensorex.t()
  def linear_modal_response(
        %Tensorex{shape: [degrees, degrees]} = mass,
        %Tensorex{shape: [degrees, degrees]} = damping,
        %Tensorex{shape: [degrees, degrees]} = stiffness,
        %Tensorex{shape: [degrees]} = amplification,
        acceleration_spectrum,
        superimpose_method
      )
      when is_function(acceleration_spectrum, 2) and superimpose_method in [:srss, :cqc] do
    {natural_angular_frequencies, mode_vectors} = normal_modes(mass, stiffness)
    beta = participation_factors(mode_vectors, mass, amplification)

    damping_factors =
      Tensorex.Analyzer.solve(
        mode_vectors
        |> Tensorex.Operator.multiply(mass, [{0, 0}])
        |> Tensorex.Operator.multiply(mode_vectors, [{1, 0}])
        |> Tensorex.Operator.multiply(natural_angular_frequencies, [{1, 0}])
        |> Tensorex.Operator.multiply(2),
        mode_vectors
        |> Tensorex.Operator.multiply(damping, [{0, 0}])
        |> Tensorex.Operator.multiply(mode_vectors, [{1, 0}])
      )

    modal_response =
      Tensorex.map(beta, fn value, [degree] ->
        natural_angular_frequency = natural_angular_frequencies[[degree, degree]]
        natural_period = 2 * :math.pi() / natural_angular_frequency
        damping_factor = damping_factors[[degree, degree]]
        standard_acceleration = acceleration_spectrum.(natural_period, damping_factor)
        value * standard_acceleration / natural_angular_frequency / natural_angular_frequency
      end)

    case superimpose_method do
      :srss ->
        superimpose(modal_response, :srss, mode_vectors)

      :cqc ->
        correlations = mode_correlation_coefficients(natural_angular_frequencies, damping_factors)
        superimpose(modal_response, :cqc, mode_vectors, correlations)
    end
  end

  @doc """
  Returns the stiffness propotional damping matrix.

      iex> Structex.Modal.stiffness_propotional_damping(
      ...>   Tensorex.from_list([[30.2, -30.2, 0], [-30.2, 70.3, -40.1], [0, -40.1, 96.5]]),
      ...>   5.236,
      ...>   0.08
      ...> )
      %Tensorex{data: %{[0, 0] =>  0.9228418640183346, [0, 1] => -0.9228418640183346,
                        [1, 0] => -0.9228418640183346, [1, 1] =>  2.1482047364400305, [1, 2] => -1.225362872421696,
                                                       [2, 1] => -1.225362872421696 , [2, 2] =>  2.948815889992361}, shape: [3, 3]}
  """
  @spec stiffness_propotional_damping(Tensorex.t(), number, number) :: Tensorex.t()
  def stiffness_propotional_damping(
        %Tensorex{shape: [degrees, degrees]} = stiffness,
        natural_angular_frequency,
        damping_ratio
      )
      when is_number(natural_angular_frequency) and natural_angular_frequency > 0 and
             is_number(damping_ratio) and damping_ratio >= 0 do
    stiffness |> Tensorex.Operator.multiply(damping_ratio * 2 / natural_angular_frequency)
  end

  @doc """
  Returns the mass propotional damping matrix.

      iex> Structex.Modal.mass_propotional_damping(
      ...>   Tensorex.from_list([[30.2, 0, 0], [0, 40.3, 0], [0, 0, 56.4]]),
      ...>   5.236,
      ...>   0.11
      ...> )
      %Tensorex{data: %{[0, 0] => 34.787984,
                                             [1, 1] => 46.422376,
                                                                  [2, 2] => 64.968288}, shape: [3, 3]}
  """
  @spec mass_propotional_damping(Tensorex.t(), number, number) :: Tensorex.t()
  def mass_propotional_damping(
        %Tensorex{shape: [degrees, degrees]} = mass,
        natural_angular_frequency,
        damping_ratio
      )
      when is_number(natural_angular_frequency) and natural_angular_frequency > 0 and
             is_number(damping_ratio) and damping_ratio >= 0 do
    mass |> Tensorex.Operator.multiply(damping_ratio * natural_angular_frequency * 2)
  end

  @doc """
  Calculates a modal damping ratio by the strain energy propotional method.

  The argument must be an enumerable of three-element tuples containing an element's stiffness
  matrix, an element's distortion vector and an element's damping ratio.

      iex> Structex.Modal.strain_energy_propotional_damping([
      ...>   {Tensorex.from_list([[0.8, -0.8], [-0.8, 0.8]]), Tensorex.from_list([0.5, 0.8]), 0.08},
      ...>   {Tensorex.from_list([[1.2, -1.2], [-1.2, 1.2]]), Tensorex.from_list([0.8, 1.0]), 0.12}
      ...> ])
      0.096
  """
  @spec strain_energy_propotional_damping(Enum.t()) :: number
  def strain_energy_propotional_damping(enumerable) do
      enumerable
    |> Stream.map(fn
      {
        %Tensorex{shape: [degrees, degrees]} = stiffness,
        %Tensorex{shape: [degrees]} = distortion,
        damping_ratio
      }
      when is_number(damping_ratio) and damping_ratio >= 0 ->
        strain_energy =
          distortion
          |> Tensorex.Operator.multiply(stiffness, [{0, 0}])
          |> Tensorex.Operator.multiply(distortion, [{0, 0}])

        {strain_energy * damping_ratio, strain_energy}
      end)
      |> Enum.unzip()
    |> Tuple.to_list()
    |> Stream.map(&Enum.sum/1)
    |> Enum.reduce(&(&2 / &1))
  end
end
