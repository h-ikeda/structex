defmodule Structex.Element.Spring do
  @moduledoc """
  Represents a spring between two nodes.

      iex> Structex.Element.equivalent_stiffness(
      ...>   %Structex.Element.Spring{
      ...>     constant: %Structex.Hysteresis.Linear{constant: 33.1},
      ...>     transformation: Tensorex.from_list([[1, 0, 0], [0, 0, 0], [0, 0, 0]])
      ...>   },
      ...>   [:first, :second],
      ...>   Structex.Tensor.new(1)
      ...>   |> Structex.Tensor.put_key(:first, [:fixed, :fixed, :fixed])
      ...>   |> Structex.Tensor.put_key(:second, [:fixed, :fixed, :fixed])
      ...> )
      [
        {[:first, :first], %Tensorex{data: %{[0, 0] =>  33.1}, shape: [3, 3]}},
        {[:first, :second], %Tensorex{data: %{[0, 0] => -33.1}, shape: [3, 3]}},
        {[:second, :first], %Tensorex{data: %{[0, 0] => -33.1}, shape: [3, 3]}},
        {[:second, :second], %Tensorex{data: %{[0, 0] =>  33.1}, shape: [3, 3]}}
      ]

      iex> Structex.Element.equivalent_stiffness(
      ...>   %Structex.Element.Spring{
      ...>     constant: %Structex.Hysteresis.Linear{constant: 33.1},
      ...>     direction: Tensorex.from_list([1, 1, 0])
      ...>   },
      ...>   [:first, :second],
      ...>   Structex.Tensor.new(1)
      ...>   |> Structex.Tensor.put_key(:first, [:fixed, :fixed, :fixed])
      ...>   |> Structex.Tensor.put_key(:second, [:fixed, :fixed, :fixed])
      ...> )
      [
        {[:first, :first], %Tensorex{data: %{[0, 0] =>  33.1}, shape: [3, 3]}},
        {[:first, :second], %Tensorex{data: %{[0, 0] => -33.1}, shape: [3, 3]}},
        {[:second, :first], %Tensorex{data: %{[0, 0] => -33.1}, shape: [3, 3]}},
        {[:second, :second], %Tensorex{data: %{[0, 0] =>  33.1}, shape: [3, 3]}}
      ]
  """
  @type t :: %Structex.Element.Spring{
          hysteresis: Structex.Hysteresis.t(),
          transformation: Tensorex.t()
        }
  defstruct [:hysteresis, :transformation]

  defimpl Structex.Element do
    def equivalent_stiffness(
          %Structex.Element.Spring{
            hysteresis: hysteresis,
            transformation: %Tensorex{shape: [degrees, degrees]} = transformation
          },
          [key1, key2],
          %Structex.Tensor{} = distortion
        ) do
      element_distortion =
        transformation
        |> Tensorex.Operator.multiply(
          distortion[[key2]]
          |> Tensorex.Operator.subtract(distortion[[key1]]),
          [{1, 0}]
        )

      partial =
        Structex.Hysteresis.equivalent_stiffness(hysteresis, element_distortion)
        |> Tensorex.Operator.multiply(transformation)

        Structex.Tensor.new(2)
        |> Structex.Tensor.put_key(key1, List.duplicate(:free, degrees))
        |> Structex.Tensor.put_key(key2, List.duplicate(:free, degrees))
        |> put_in([key1, key1], partial)
        |> put_in([key1, key2], Tensorex.Operator.negate(partial))
        |> put_in([key2, key1], Tensorex.Operator.negate(partial))
        |> put_in([key2, key2], partial)
    end
  end
end
