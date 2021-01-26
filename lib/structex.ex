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
  Composes each matrix of the element into a system matrix.

  The first argument must be a list of two-element tuple where the first element is a 2-dimension
  list of matrices (2-rank `t:Tensorex.t/0`) and the second one is a list of node identifiers. The
  matrices at the same node identifier will be sumed up.

  If the second argument is passed, the element order respects what range to be used for each node
  identifier.

      iex> Structex.compose([
      ...>   {[[Tensorex.from_list([[10, 0], [0, 10]])]], [0]},
      ...>   {[[Tensorex.from_list([[ 5, 0], [0,  5]])]], [1]}
      ...> ])
      {
        %Tensorex{data: %{[0, 0] =>  10,
                                         [1, 1] =>  10,
                                                        [2, 2] => 5,
                                                                     [3, 3] => 5}, shape: [4, 4]},
        %{0 => 0..1, 1 => 2..3}
      }

      iex> Structex.compose([
      ...>   {
      ...>     [[Tensorex.from_list([[32.1, 0], [0, 42.1]]), Tensorex.from_list([[-32.1, 0], [0, -42.1]])], [Tensorex.from_list([[-32.1, 0], [0, -42.1]]), Tensorex.from_list([[32.1, 0], [0, 42.1]])]],
      ...>     [0, 1]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[24  , 0], [0, 14  ]]), Tensorex.from_list([[-24  , 0], [0, -14  ]])], [Tensorex.from_list([[-24  , 0], [0, -14  ]]), Tensorex.from_list([[24  , 0], [0, 14  ]])]],
      ...>     [1, 2]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[63.1, 0], [0, 55.3]])]],
      ...>     [0]
      ...>   }
      ...> ])
      {
        %Tensorex{data: %{[0, 0] =>  95.2,                  [0, 2] => -32.1,
                                           [1, 1] =>  97.4,                  [1, 3] => -42.1,
                          [2, 0] => -32.1,                  [2, 2] =>  56.1,                  [2, 4] => -24,
                                           [3, 1] => -42.1,                  [3, 3] =>  56.1,                [3, 5] => -14,
                                                            [4, 2] => -24  ,                  [4, 4] =>  24,
                                                                             [5, 3] => -14  ,                [5, 5] =>  14}, shape: [6, 6]},
        %{0 => 0..1, 1 => 2..3, 2 => 4..5}
      }

      iex> Structex.compose([
      ...>   {
      ...>     [[Tensorex.from_list([[32.1, 0], [0, 42.1]]), Tensorex.from_list([[-32.1, 0], [0, -42.1]])], [Tensorex.from_list([[-32.1, 0], [0, -42.1]]), Tensorex.from_list([[32.1, 0], [0, 42.1]])]],
      ...>     [0, 1]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[24  , 0], [0, 14  ]]), Tensorex.from_list([[-24  , 0], [0, -14  ]])], [Tensorex.from_list([[-24  , 0], [0, -14  ]]), Tensorex.from_list([[24  , 0], [0, 14  ]])]],
      ...>     [1, 2]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[ 5  , 0], [0,  8  ]]), Tensorex.from_list([[ -5  , 0], [0,  -8  ]])], [Tensorex.from_list([[ -5  , 0], [0,  -8  ]]), Tensorex.from_list([[ 5  , 0], [0,  8  ]])]],
      ...>     [3, 2]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[ 3.9, 0], [0,  6.5]]), Tensorex.from_list([[ -3.9, 0], [0,  -6.5]])], [Tensorex.from_list([[ -3.9, 0], [0,  -6.5]]), Tensorex.from_list([[ 3.9, 0], [0,  6.5]])]],
      ...>     [4, 5]
      ...>   },
      ...>   {
      ...>     [[Tensorex.from_list([[63.1, 0], [0, 55.3]])]],
      ...>     [0]
      ...>   }
      ...> ], %{1 => 0..1, 2 => 2..3})
      {
        %Tensorex{data: %{[0, 0] =>  56.1,                  [0, 2] => -24,                [0, 4] => -32.1,
                                           [1, 1] =>  56.1,                [1, 3] => -14,                  [1, 5] => -42.1,
                          [2, 0] => -24  ,                  [2, 2] =>  29,                                                  [2, 6] => -5,
                                           [3, 1] => -14  ,                [3, 3] =>  22,                                                 [3, 7] => -8,
                          [4, 0] => -32.1,                                                [4, 4] =>  95.2,
                                           [5, 1] => -42.1,                                                [5, 5] =>  97.4,
                                                            [6, 2] =>  -5,                                                  [6, 6] =>  5,
                                                                           [7, 3] =>  -8,                                                 [7, 7] =>  8,
                                                                                                                                                        [ 8, 8] =>  3.9,                  [ 8, 10] => -3.9,
                                                                                                                                                                         [ 9, 9] =>  6.5,                   [ 9, 11] => -6.5,
                                                                                                                                                        [10, 8] => -3.9,                  [10, 10] =>  3.9,
                                                                                                                                                                         [11, 9] => -6.5,                   [11, 11] =>  6.5}, shape: [12, 12]},
        %{0 => 4..5, 1 => 0..1, 2 => 2..3, 3 => 6..7, 4 => 8..9, 5 => 10..11}
      }
  """
  @spec compose(Enum.t(), %{term => Range.t()}) :: {Tensorex.t(), %{term => Range.t()}}
  def compose(matrix_and_node_ids, range_indices \\ %{}) do
    {elements, new_range_indices} =
      Enum.map_reduce(matrix_and_node_ids, range_indices, fn {matrices, nodes}, acc ->
        Stream.zip(matrices, nodes)
        |> Stream.map(fn {row, node} ->
          Stream.zip(row, nodes) |> Stream.map(&Tuple.insert_at(&1, 1, node))
        end)
        |> Stream.concat()
        |> Enum.map_reduce(acc, fn
          {%Tensorex{} = matrix, node1, node2}, ranges
          when is_map_key(ranges, node1) and is_map_key(ranges, node2) ->
            size = max(Enum.max(ranges[node1]), Enum.max(ranges[node2])) + 1
            {put_in(Tensorex.zero([size, size])[[ranges[node1], ranges[node2]]], matrix), ranges}

          {%Tensorex{shape: [degree | _]} = matrix, node1, node2}, ranges
          when is_map_key(ranges, node1) ->
            max_index = Map.values(ranges) |> Stream.map(&Enum.max/1) |> Enum.max(fn -> -1 end)
            new_max_index = max_index + degree
            range = (max_index + 1)..new_max_index
            size = new_max_index + 1

            {
              put_in(Tensorex.zero([size, size])[[ranges[node1], range]], matrix),
              Map.put(ranges, node2, range)
            }

          {%Tensorex{shape: [degree | _]} = matrix, node, node}, ranges ->
            max_index = Map.values(ranges) |> Stream.map(&Enum.max/1) |> Enum.max(fn -> -1 end)
            new_max_index = max_index + degree
            range = (max_index + 1)..new_max_index
            size = new_max_index + 1

            {
              put_in(Tensorex.zero([size, size])[[range, range]], matrix),
              Map.put(ranges, node, range)
            }
        end)
      end)

    composed =
      Stream.concat(elements)
      |> Enum.reduce(fn
        %Tensorex{shape: [deg1 | _]} = element1, %Tensorex{shape: [deg2 | _] = shape} = element2
        when deg1 < deg2 ->
          element1 |> Tensorex.reshape(shape) |> Tensorex.Operator.add(element2)

        %Tensorex{shape: [degree | _]} = element1, %Tensorex{shape: [degree | _]} = element2 ->
          element2 |> Tensorex.Operator.add(element1)

        %Tensorex{shape: shape} = element1, element2 ->
          element2 |> Tensorex.reshape(shape) |> Tensorex.Operator.add(element1)
      end)

    {composed, new_range_indices}
  end

  @doc """
  The standard acceleration due to gravity on the surface of the earth.
  """
  @spec standard_gravity_acceleration() :: float
  def standard_gravity_acceleration(), do: 9.80665
end
