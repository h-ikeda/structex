defmodule Structex.Tensor do
  @moduledoc """
  Tensors which block of elements are identified by registered keys.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2, [0, 2] => 3,
                        [1, 0] => 4, [1, 1] => 5, [1, 2] => 6,
                        [2, 0] => 7, [2, 1] => 8, [2, 2] => 9,
                                                               [3, 3] => 11, [3, 4] => 12, [3, 5] => 13,
                                                               [4, 3] => 14, [4, 4] => 15, [4, 5] => 16,
                                                               [5, 3] => 17, [5, 4] => 18, [5, 5] => 19,
                                                                                                         [6, 6] => 21, [6, 7] => 23,
                                                                                                         [7, 6] => 27, [7, 7] => 29,
                                                               [8, 3] => 57, [8, 4] => 58, [8, 5] => 59, [8, 6] => 67, [8, 7] => 69, [8, 8] => 39,
                                                                                                                                                   [ 9, 9] => 41, [ 9, 10] => 42, [ 9, 11] => 43,
                                                                                                                                                   [10, 9] => 44, [10, 10] => 45, [10, 11] => 46,
                                                                                                                                                   [11, 9] => 47, [11, 10] => 48, [11, 11] => 49}, shape: [12, 12]}
  """
  @opaque t :: %Structex.Tensor{
            tensor: Tensorex.t() | pos_integer,
            index: %{optional(term) => {non_neg_integer, [Range.t()], pos_integer}}
          }
  defstruct [:tensor, :index]
  @behaviour Access
  @doc """
  Returns a partial tensor corresponding to the given keys.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_in([[:c, :d]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_in([[:d, :c]])
      %Tensorex{data: %{[2, 0] => 67, [2, 2] => 69}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:c, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :fixed])
      ...> |> get_in([[:c, :d]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:c, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :fixed])
      ...> |> get_in([[:a, :d]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_in([[:f, :a]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> get_in([[:a, :a]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_in([[:a]])
      ** (FunctionClauseError) no function clause matching in Structex.Tensor.fetch/2
  """
  @spec fetch(t, [...]) :: :error | {:ok, Tensorex.t()}
  def fetch(%Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor, index: index}, keys)
      when is_list(keys) and length(keys) === length(shape) do
    try do
      {ranges, new_shape} = ranges_and_shape(index, keys)
      new_tensor = permutation(ranges) |> put_left_to_right(tensor, Tensorex.zero(new_shape))
      {:ok, new_tensor}
    rescue
      KeyError -> :error
    end
  end

  def fetch(%Structex.Tensor{tensor: order, index: index}, keys)
      when is_list(keys) and length(keys) === order do
    if Enum.all?(keys, &is_map_key(index, &1)) do
      {:ok, Tensorex.zero(Enum.map(keys, &elem(index[&1], 2)))}
    else
      :error
    end
  end

  @spec put_left_to_right(Enum.t(), Tensorex.t(), Tensorex.t()) :: Tensorex.t()
  defp put_left_to_right(perm, left, right) do
    Enum.reduce(perm, right, fn {left_index, right_index}, acc ->
      put_in(acc[right_index], left[left_index])
    end)
  end

  @spec put_right_to_left(Enum.t(), Tensorex.t(), Tensorex.t()) :: Tensorex.t()
  defp put_right_to_left(perm, left, right) do
    Enum.reduce(perm, left, fn {left_index, right_index}, acc ->
      put_in(acc[left_index], right[right_index])
    end)
  end

  @doc """
  Gets and updates partial elements specified by the given keys.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> update_in([[:a, :a]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]])) end)
      ...> |> update_in([[:b, :b]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]])) end)
      ...> |> update_in([[:c, :c]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]])) end)
      ...> |> update_in([[:d, :d]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]])) end)
      ...> |> update_in([[:e, :e]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]])) end)
      ...> |> update_in([[:d, :b]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]])) end)
      ...> |> update_in([[:d, :c]], fn x -> Tensorex.Operator.add(x, Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]])) end)
      ...> |> update_in([[:a, :a]], fn x -> Tensorex.Operator.add(x, x) end)
      ...> |> update_in([[:d, :b]], fn x -> Tensorex.Operator.negate(x) end)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] =>  2, [0, 1] =>  4, [0, 2] =>  6,
                        [1, 0] =>  8, [1, 1] => 10, [1, 2] => 12,
                        [2, 0] => 14, [2, 1] => 16, [2, 2] => 18,
                                                                  [3, 3] =>  11, [3, 4] =>  12, [3, 5] =>  13,
                                                                  [4, 3] =>  14, [4, 4] =>  15, [4, 5] =>  16,
                                                                  [5, 3] =>  17, [5, 4] =>  18, [5, 5] =>  19,
                                                                                                               [6, 6] => 21, [6, 7] => 23,
                                                                                                               [7, 6] => 27, [7, 7] => 29,
                                                                  [8, 3] => -57, [8, 4] => -58, [8, 5] => -59, [8, 6] => 67, [8, 7] => 69, [8, 8] => 39,
                                                                                                                                                         [ 9, 9] => 41, [ 9, 10] => 42, [ 9, 11] => 43,
                                                                                                                                                         [10, 9] => 44, [10, 10] => 45, [10, 11] => 46,
                                                                                                                                                         [11, 9] => 47, [11, 10] => 48, [11, 11] => 49}, shape: [12, 12]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_and_update_in([[:b, :b]], fn _ -> :pop end)
      ...> |> elem(0)
      %Tensorex{data: %{[0, 0] => 11, [0, 1] => 12, [0, 2] => 13,
                        [1, 0] => 14, [1, 1] => 15, [1, 2] => 16,
                        [2, 0] => 17, [2, 1] => 18, [2, 2] => 19}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> get_and_update_in([[:b, :b]], fn _ -> :pop end)
      ...> |> elem(1)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2, [0, 2] => 3,
                        [1, 0] => 4, [1, 1] => 5, [1, 2] => 6,
                        [2, 0] => 7, [2, 1] => 8, [2, 2] => 9,
                                                                                                         [6, 6] => 21, [6, 7] => 23,
                                                                                                         [7, 6] => 27, [7, 7] => 29,
                                                               [8, 3] => 57, [8, 4] => 58, [8, 5] => 59, [8, 6] => 67, [8, 7] => 69, [8, 8] => 39,
                                                                                                                                                   [ 9, 9] => 41, [ 9, 10] => 42, [ 9, 11] => 43,
                                                                                                                                                   [10, 9] => 44, [10, 10] => 45, [10, 11] => 46,
                                                                                                                                                   [11, 9] => 47, [11, 10] => 48, [11, 11] => 49}, shape: [12, 12]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:c, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :fixed])
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> get_and_update_in([[:c, :c]], fn x -> {x, Tensorex.Operator.add(x, x)} end)
      ...> |> elem(0)
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:c, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :fixed])
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> get_and_update_in([[:c, :c]], fn x -> {x, Tensorex.Operator.add(x, x)} end)
      ...> |> elem(1)
      ...> |> Structex.Tensor.assembled()
      nil
  """
  @spec get_and_update(t, [...], (Tensorex.t() -> {any, Tensorex.t()} | :pop)) ::
          {Tensorex.t(), t}
  def get_and_update(
        %Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor, index: index} = t,
        keys,
        fun
      )
      when is_list(keys) and length(shape) === length(keys) do
    {conversion_ranges, new_shape} = ranges_and_shape(index, keys)
    conversion_indices = permutation(conversion_ranges) |> Enum.to_list()
    value = conversion_indices |> put_left_to_right(tensor, Tensorex.zero(new_shape))

    case fun.(value) do
      {get_value, update_value} ->
        new_tensor = conversion_indices |> put_right_to_left(tensor, update_value)
        {get_value, %{t | tensor: new_tensor}}

      :pop ->
        new_tensor =
          Enum.reduce(conversion_indices, tensor, fn {range, _}, acc ->
            pop_in(acc[range]) |> elem(1)
          end)

        {value, %{t | tensor: new_tensor}}
    end
  end

  def get_and_update(%Structex.Tensor{tensor: order, index: index} = t, keys, fun)
      when is_list(keys) and order === length(keys) do
    shape = Enum.map(keys, &elem(Map.fetch!(index, &1), 2))

    case fun.(Tensorex.zero(shape)) do
      {get_value, %Tensorex{shape: ^shape}} -> {get_value, t}
      :pop -> {Tensorex.zero(shape), t}
    end
  end

  @spec ranges_and_shape(%{optional(term) => {non_neg_integer, [Range.t()], pos_integer}}, [...]) ::
          {[[{Range.t(), Range.t()}], ...], [pos_integer, ...]}
  defp ranges_and_shape(index, keys) do
    Stream.map(keys, fn key ->
      {pos, ranges, size} = Map.fetch!(index, key)

      {each_conversion_ranges, _} =
        Enum.map_reduce(ranges, pos, fn range, acc ->
          next_acc = acc + Enum.count(range)
          {{acc..(next_acc - 1), range}, next_acc}
        end)

      {each_conversion_ranges, size}
    end)
    |> Enum.unzip()
  end

  @spec permutation(Enum.t()) :: Enum.t()
  defp permutation(enumerable_of_range_pairs) do
    Enum.reduce(enumerable_of_range_pairs, [{[], []}], fn range_pairs, acc ->
      Stream.map(range_pairs, fn {left, right} ->
        Stream.map(acc, fn {prev_left, prev_right} ->
          {[left | prev_left], [right | prev_right]}
        end)
      end)
      |> Stream.concat()
    end)
    |> Stream.map(fn {left, right} -> {Enum.reverse(left), Enum.reverse(right)} end)
  end

  @doc """
  Pops partial elements specified by the given keys.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> pop_in([[:c, :c]])
      ...> |> elem(0)
      %Tensorex{data: %{[0, 0] => 21, [0, 2] => 23,
                        [2, 0] => 27, [2, 2] => 29}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> pop_in([[:c, :c]])
      ...> |> elem(1)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2, [0, 2] => 3,
                        [1, 0] => 4, [1, 1] => 5, [1, 2] => 6,
                        [2, 0] => 7, [2, 1] => 8, [2, 2] => 9,
                                                               [3, 3] => 11, [3, 4] => 12, [3, 5] => 13,
                                                               [4, 3] => 14, [4, 4] => 15, [4, 5] => 16,
                                                               [5, 3] => 17, [5, 4] => 18, [5, 5] => 19,
                                                               [8, 3] => 57, [8, 4] => 58, [8, 5] => 59, [8, 8] => 39,
                                                                                                                       [ 9, 9] => 41, [ 9, 10] => 42, [ 9, 11] => 43,
                                                                                                                       [10, 9] => 44, [10, 10] => 45, [10, 11] => 46,
                                                                                                                       [11, 9] => 47, [11, 10] => 48, [11, 11] => 49}, shape: [12, 12]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:fixed, :fixed, :fixed])
      ...> |> pop_in([[:a, :b]])
      ...> |> elem(0)
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:fixed, :fixed, :fixed])
      ...> |> pop_in([[:a, :b]])
      ...> |> elem(1)
      ...> |> Structex.Tensor.assembled()
      nil
  """
  @spec pop(t, [...]) :: {Tensorex.t(), t}
  def pop(%Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor, index: index} = t, keys)
      when is_list(keys) and length(keys) === length(shape) do
    {conversion_ranges, new_shape} = ranges_and_shape(index, keys)
    conversion_indices = permutation(conversion_ranges) |> Enum.to_list()
    value = conversion_indices |> put_left_to_right(tensor, Tensorex.zero(new_shape))

    new_tensor =
      Enum.reduce(conversion_indices, tensor, fn {range, _}, acc ->
        pop_in(acc[range]) |> elem(1)
      end)

    {value, %{t | tensor: new_tensor}}
  end

  def pop(%Structex.Tensor{tensor: order, index: index} = t, keys)
      when is_list(keys) and length(keys) === order do
    {Tensorex.zero(Enum.map(keys, &elem(Map.fetch!(index, &1), 2))), t}
  end

  @doc """
  Creates a new tensor.
  """
  @spec new(pos_integer) :: t
  def new(order), do: %Structex.Tensor{tensor: order, index: %{}}

  @doc """
  Unregisters a key from the tensor.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> get_in([[:a, :b]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{}, shape: [2, 2]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> get_in([[:a, :b]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free ])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free ])
      ...> |> Structex.Tensor.put_key(:c, [:free, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> get_in([[:c, :b]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free ])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free ])
      ...> |> Structex.Tensor.put_key(:c, [:free, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> get_in([[:c, :a]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free ])
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free ])
      ...> |> Structex.Tensor.put_key(:c, [:free, :fixed, :fixed])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2, [0, 2] => 3,
                        [1, 0] => 4, [1, 1] => 5, [1, 2] => 6,
                        [2, 0] => 7, [2, 1] => 8, [2, 2] => 9,
                                                               [3, 3] => 21}, shape: [4, 4]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free, :free])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> get_in([[:a, :a]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free, :free])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> Structex.Tensor.assembled()
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> get_in([[:a, :a]])
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> Structex.Tensor.assembled()
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :fixed])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> get_in([[:b, :b]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :fixed])
      ...> |> Structex.Tensor.delete_key(:a)
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{}, shape: [2, 2]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> get_in([[:a, :a]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> Structex.Tensor.assembled()
      nil

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> get_in([[:a, :a]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.put_key(:b, [:fixed, :fixed, :fixed])
      ...> |> Structex.Tensor.delete_key(:b)
      ...> |> Structex.Tensor.assembled()
      nil
  """
  @spec delete_key(t, term) :: t
  def delete_key(%Structex.Tensor{tensor: %Tensorex{shape: shape}, index: index}, key)
      when is_map_key(index, key) and map_size(index) <= 1 do
    new(length(shape))
  end

  def delete_key(%Structex.Tensor{tensor: order, index: index}, key)
      when is_map_key(index, key) and map_size(index) <= 1 do
    new(order)
  end

  def delete_key(
        %Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor, index: index} = t,
        key
      )
      when is_map_key(index, key) do
    case Map.pop(index, key) do
      {{nil, [], _}, new_index} ->
        %{t | index: new_index}

      {{start, ranges, _}, new_index} ->
        unless Enum.any?(new_index, fn {_, {s, _, _}} -> s end) do
          %{t | tensor: length(shape), index: new_index}
        else
          shift = Stream.map(ranges, &Enum.count/1) |> Enum.sum()
          shifted_index = Enum.into(new_index, %{}, &shift_index(&1, -shift, start))

          new_tensor =
            cond do
              start <= 0 ->
                tensor[List.duplicate(shift..(List.first(shape) - 1), length(shape))]

              start + shift >= List.first(shape) ->
                tensor[List.duplicate(0..(start - 1), length(shape))]

              true ->
                new_shape = Enum.map(shape, &(&1 - shift))
                max_index = List.first(shape) - 1
                bf = {0..(start - 1), 0..(start - 1)}
                af = {(start + shift)..max_index, start..(max_index - shift)}

                Stream.cycle([[bf, af]])
                |> Stream.take(length(shape))
                |> permutation()
                |> put_left_to_right(tensor, Tensorex.zero(new_shape))
            end

          %{t | tensor: new_tensor, index: shifted_index}
        end
    end
  end

  def delete_key(%Structex.Tensor{index: index} = t, key),
    do: %{t | index: Map.delete(index, key)}

  @spec shift_index({term, {non_neg_integer, [Range.t()], pos_integer}}, integer, non_neg_integer) ::
          {term, {non_neg_integer, [Range.t()], pos_integer}}
  defp shift_index({_, {pos, _, _}} = original, _, from) when pos < from, do: original
  defp shift_index({key, {pos, ranges, size}}, shift, _), do: {key, {pos + shift, ranges, size}}

  @doc """
  Registers a key with boundary conditions.

  The argument `degrees` is an enumerable of `:free` or `:fixed` those represents boundary
  conditions. If `:fixed` is specified, that degree will ignore input values and the assembled
  tensor will be contracted.

  When the given key already exists, the key will be overwritten. It does not conserve existing
  values at the key.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free, :free , :free])
      ...> |> put_in([[:a, :b]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> get_in([[:a, :b]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free, :free , :free])
      ...> |> put_in([[:a, :b]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> get_in([[:b, :b]])
      %Tensorex{data: %{}, shape: [3, 3]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free, :free , :free])
      ...> |> put_in([[:a, :b]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> Structex.Tensor.put_key(:b, [:free, :fixed, :free])
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[3, 3] => 21, [3, 4] => 22, [3, 5] => 23,
                        [4, 3] => 24, [4, 4] => 25, [4, 5] => 26,
                        [5, 3] => 27, [5, 4] => 28, [5, 5] => 29}, shape: [8, 8]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free , :invalid])
      ** (RuntimeError) expected boundary condition to be :fixed or :free, got: :invalid
  """
  @spec put_key(t, term, Enum.t()) :: t
  def put_key(%Structex.Tensor{index: index} = t, key, degrees) when is_map_key(index, key) do
    put_key(delete_key(t, key), key, degrees)
  end

  def put_key(
        %Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor, index: index} = t,
        key,
        degrees
      ) do
    {new_index, range_size} = create_index(degrees, List.first(shape))
    new_shape = Enum.map(shape, &(&1 + range_size))
    %{t | tensor: Tensorex.reshape(tensor, new_shape), index: Map.put(index, key, new_index)}
  end

  def put_key(%Structex.Tensor{tensor: order, index: index} = t, key, degrees) do
    case create_index(degrees, 0) do
      {new_index, 0} ->
        %{t | index: Map.put(index, key, new_index)}

      {new_index, range_size} ->
        shape = List.duplicate(range_size, order)
        %{t | tensor: Tensorex.zero(shape), index: Map.put(index, key, new_index)}
    end
  end

  @spec create_index(Enum.t(), non_neg_integer) ::
          {{non_neg_integer, [Range.t()], pos_integer}, non_neg_integer}
  defp create_index(degrees, pos) do
    {ranges, {total_count, free_count}} =
      Stream.with_index(degrees)
      |> Stream.chunk_by(&elem(&1, 0))
      |> Enum.map_reduce({0, 0}, fn
        [{:free, from} | _] = chunk, {total, frees} ->
          {from..elem(List.last(chunk), 1), {total + length(chunk), frees + length(chunk)}}

        [{:fixed, _} | _] = chunk, {total, frees} ->
          {nil, {total + length(chunk), frees}}

        [{condition, _} | _], _ ->
          raise "expected boundary condition to be :fixed or :free, got: #{inspect(condition)}"
      end)

    {{(free_count > 0 and pos) || nil, Enum.filter(ranges, & &1), total_count}, free_count}
  end

  @doc """
  Returns the assembled and contracted tensor.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:b, [:free , :free , :free])
      ...> |> Structex.Tensor.put_key(:c, [:free , :fixed, :free])
      ...> |> Structex.Tensor.put_key(:d, [:fixed, :fixed, :free])
      ...> |> Structex.Tensor.put_key(:e, [:free , :free , :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2,  3], [ 4,  5,  6], [ 7,  8,  9]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12, 13], [14, 15, 16], [17, 18, 19]]))
      ...> |> put_in([[:c, :c]], Tensorex.from_list([[21, 22, 23], [24, 25, 26], [27, 28, 29]]))
      ...> |> put_in([[:d, :d]], Tensorex.from_list([[31, 32, 33], [34, 35, 36], [37, 38, 39]]))
      ...> |> put_in([[:e, :e]], Tensorex.from_list([[41, 42, 43], [44, 45, 46], [47, 48, 49]]))
      ...> |> put_in([[:d, :b]], Tensorex.from_list([[51, 52, 53], [54, 55, 56], [57, 58, 59]]))
      ...> |> put_in([[:d, :c]], Tensorex.from_list([[61, 62, 63], [64, 65, 66], [67, 68, 69]]))
      ...> |> Structex.Tensor.assembled()
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2, [0, 2] => 3,
                        [1, 0] => 4, [1, 1] => 5, [1, 2] => 6,
                        [2, 0] => 7, [2, 1] => 8, [2, 2] => 9,
                                                               [3, 3] => 11, [3, 4] => 12, [3, 5] => 13,
                                                               [4, 3] => 14, [4, 4] => 15, [4, 5] => 16,
                                                               [5, 3] => 17, [5, 4] => 18, [5, 5] => 19,
                                                                                                         [6, 6] => 21, [6, 7] => 23,
                                                                                                         [7, 6] => 27, [7, 7] => 29,
                                                               [8, 3] => 57, [8, 4] => 58, [8, 5] => 59, [8, 6] => 67, [8, 7] => 69, [8, 8] => 39,
                                                                                                                                                   [ 9, 9] => 41, [ 9, 10] => 42, [ 9, 11] => 43,
                                                                                                                                                   [10, 9] => 44, [10, 10] => 45, [10, 11] => 46,
                                                                                                                                                   [11, 9] => 47, [11, 10] => 48, [11, 11] => 49}, shape: [12, 12]}
  """
  @spec assembled(t) :: Tensorex.t()
  def assembled(%Structex.Tensor{tensor: %Tensorex{} = tensor}), do: tensor
  def assembled(%Structex.Tensor{}), do: nil

  @doc """
  Overwrites the whole assembled tensor by the given tensor.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free])
      ...> |> Structex.Tensor.put_assembled(Tensorex.from_list([[ 1,  2,  3,  4],
      ...>                                               [ 5,  6,  7,  8],
      ...>                                               [ 9, 10, 11, 12],
      ...>                                               [13, 14, 15, 16]]))
      ...> |> get_in([[:a, :a]])
      %Tensorex{data: %{[0, 0] => 1, [0, 1] => 2,
                        [1, 0] => 5, [1, 1] => 6}, shape: [2, 2]}

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free])
      ...> |> Structex.Tensor.put_assembled(Tensorex.from_list([[ 1,  2,  3,  4],
      ...>                                               [ 5,  6,  7,  8],
      ...>                                               [ 9, 10, 11, 12],
      ...>                                               [13, 14, 15, 16]]))
      ...> |> get_in([[:a, :b]])
      %Tensorex{data: %{[0, 0] => 3, [0, 1] => 4,
                        [1, 0] => 7, [1, 1] => 8}, shape: [2, 2]}
  """
  @spec put_assembled(t, Tensorex.t()) :: t
  def put_assembled(
        %Structex.Tensor{tensor: %Tensorex{shape: shape}} = t,
        %Tensorex{shape: shape} = tensor
      ) do
    %{t | tensor: tensor}
  end

  @doc """
  Updates the whole assembled tensor by the given function.

      iex> Structex.Tensor.new(2)
      ...> |> Structex.Tensor.put_key(:a, [:free, :free])
      ...> |> Structex.Tensor.put_key(:b, [:free, :free])
      ...> |> put_in([[:a, :a]], Tensorex.from_list([[ 1,  2], [ 3,  4]]))
      ...> |> put_in([[:b, :b]], Tensorex.from_list([[11, 12], [13, 14]]))
      ...> |> Structex.Tensor.update_assembled(&Tensorex.Operator.negate/1)
      ...> |> get_in([[:a, :a]])
      %Tensorex{data: %{[0, 0] => -1, [0, 1] => -2,
                        [1, 0] => -3, [1, 1] => -4}, shape: [2, 2]}
  """
  @spec update_assembled(t, (Tensorex.t() -> Tensorex.t())) :: t
  def update_assembled(%Structex.Tensor{tensor: %Tensorex{shape: shape} = tensor} = t, update_fun)
      when is_function(update_fun, 1) do
    %Tensorex{shape: ^shape} = updated = update_fun.(tensor)
    %{t | tensor: updated}
  end
end
