defmodule Structex.Math do
  @moduledoc """
  Mathmatic utility functions.
  """
  @doc """
  Returns the Euler's constant.

      iex> Structex.Math.euler_constant()
      0.5772156649015329
  """
  @spec euler_constant() :: float
  def euler_constant(), do: 0.57721566490153286

  @doc """
  Calculates the sine integral at the given x.

      iex> Structex.Math.sine_integral(10.5)
      1.6229406928080434
  """
  @spec sine_integral(number) :: float
  def sine_integral(x) when is_number(x) do
    Stream.iterate(1, &(&1 + 2))
    |> Stream.map(fn
      n when rem(n, 4) === 1 -> :math.pow(x, n) / n / factorial(n)
      n -> -:math.pow(x, n) / n / factorial(n)
    end)
    |> Stream.scan(&(&1 + &2))
    |> Stream.chunk_every(2, 1)
    |> Enum.find(fn [a, b] -> a === b end)
    |> List.first()
  end

  @doc """
  Calculates the cosine integral at the given x.

      iex> Structex.Math.cos_integral(7.4)
      0.11035766582837603
  """
  @spec cos_integral(number) :: float
  def cos_integral(x) when is_number(x) do
    Stream.iterate(2, &(&1 + 2))
    |> Stream.map(fn
      n when rem(n, 4) === 0 -> :math.pow(x, n) / n / factorial(n)
      n -> -:math.pow(x, n) / n / factorial(n)
    end)
    |> Stream.scan(&(&1 + &2))
    |> Stream.chunk_every(2, 1)
    |> Stream.filter(fn [a, b] -> a === b end)
    |> Stream.map(&(List.first(&1) + euler_constant() + :math.log(x)))
    |> Enum.at(0)
  end

  @doc """
  Calculates the Riemann's zeta at the given s.

      iex> Structex.Math.riemann_zeta(4.5)
      1.0547075107614539
  """
  @spec riemann_zeta(number) :: float
  def riemann_zeta(s) when is_number(s) do
    Stream.iterate({[1 / (2 - :math.pow(2, 2 - s))], 0}, fn {prev, m} ->
      n = m + 1

      next =
        Stream.with_index(prev)
        |> Stream.flat_map(fn
          {a, ^m} ->
            [0.5 * n * a, -:math.pow(n / (n + 1), s) * 0.5 * a]

          {a, k} ->
            [0.5 * n / (n - k) * a]
        end)

      {next, n}
    end)
    |> Stream.map(&Enum.sum(elem(&1, 0)))
    |> Stream.scan(&(&1 + &2))
    |> Stream.chunk_every(2, 1)
    |> Enum.find(fn [a, b] -> a === b end)
    |> List.first()
  end

  @doc """
  Returns the factorial of the given integer.

      iex> Structex.Math.factorial(5)
      120

      iex> Structex.Math.factorial(0)
      1
  """
  @spec factorial(non_neg_integer) :: pos_integer
  def factorial(n) when is_integer(n) and n > 0, do: Enum.reduce(n..1, &(&1 * &2))
  def factorial(0), do: 1

  @doc """
  Returns a stream of the cosine fourier coefficients found from the given function.

  Any even functions in the section 0 to L are converted into following form:

      a0 / 2 + a1 * cos(π * x / L) + a2 * cos(2 * π * x / L) + ... + an * cos(n * π * x / L) + ...

  Each element of the stream is the coefficient (`an`).

      iex> Structex.Math.cos_fourier_coefficients(fn x -> x * x end, 10)
      ...> |> Enum.take(4)
      [66.666688733063, -40.52848588002486, 10.132114496770937, -4.503162285529346]

      iex> Structex.Math.cos_fourier_coefficients(fn x -> :math.exp(-x * x) end, 5)
      ...> |> Enum.take(5)
      [0.354490683415815, 0.32117495350741576, 0.23886485410627484, 0.14582657864122306, 0.07307936856926017]
  """
  def cos_fourier_coefficients(
        fun,
        half_period,
        relative_tolerance \\ 1.49e-8,
        absolute_tolerance \\ 1.49e-8
      )
      when is_function(fun, 1) and is_number(half_period) and
             is_number(relative_tolerance) and relative_tolerance >= 0 and
             is_number(absolute_tolerance) and absolute_tolerance >= 0 do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn n ->
      integral(
        &(fun.(&1) * :math.cos(n * :math.pi() * &1 / half_period)),
        0,
        half_period,
        relative_tolerance,
        absolute_tolerance
      )
    end)
    |> Stream.map(&(&1 * 2 / half_period))
  end

  @doc """
  Returns the Integration of the function on the given section.

      iex> Structex.Math.integral(&:math.sin/1, 0, :math.pi())
      1.9999994541202957

      iex> Structex.Math.integral(&:math.cos/1, -:math.pi(), :math.pi())
      -1.9968905867157015e-8

      iex> Structex.Math.integral(&(&1 * &1), 0, 5)
      41.66668045816437
  """
  @spec integral((number -> number), number, number, number, number) :: float
  def integral(fun, from, to, relative_tolerance \\ 1.49e-8, absolute_tolerance \\ 1.49e-8)
      when is_function(fun, 1) and is_number(from) and is_number(to) and
             is_number(relative_tolerance) and relative_tolerance >= 0 and
             is_number(absolute_tolerance) and absolute_tolerance >= 0 do
    converted = fn t ->
      u = :math.tanh(:math.pi() * 0.5 * :math.sinh(t))
      du = :math.cosh(t) / :math.pow(:math.cosh(:math.pi() * 0.5 * :math.sinh(t)), 2)
      fun.(from + (to - from) * 0.5 * (u + 1)) * du
    end

    Stream.iterate(0.5, &(&1 * 0.5))
    |> Stream.map(fn step ->
      Stream.iterate(step * 0.5, &(&1 + step))
      |> Stream.map(&(converted.(&1) + converted.(-&1)))
      |> Stream.chunk_by(&trunc(:math.log2(abs(&1))))
      |> Stream.map(&Enum.sum/1)
      |> Stream.scan(&(&1 + &2))
      |> Stream.chunk_every(2, 1)
      |> Stream.filter(fn [a, b] -> a === b end)
      |> Stream.map(&(List.first(&1) * step))
      |> Enum.at(0)
    end)
    |> Stream.scan(&((&1 * 2 + &2) / 3))
    |> richardson_extrapolation()
    |> Stream.chunk_every(2, 1)
    |> Stream.filter(fn [a, b] -> abs((a - b) / b) <= 1.0e-6 or abs(a - b) <= 1.0e-8 end)
    |> Stream.map(&(List.last(&1) * 0.25 * :math.pi() * (to - from)))
    |> Enum.at(0)
  end

  defp richardson_extrapolation(enumerable) do
    Stream.unfold({enumerable, 4}, fn {acc, c} ->
      next =
        Stream.chunk_every(acc, 2, 1)
        |> Stream.map(fn [prev1, prev2] -> (prev2 * c - prev1) / (c - 1) end)

      {Enum.at(next, 0), {next, c * 4}}
    end)
  end

  @doc """
  Returns the linear interpolated value from the given dataset.

  The argument `enumerable` must be sorted in ascending order.

      iex> Structex.Math.linear_interpolation([{1, 1}, {1.5, 2}, {2.5, 2.8}, {4, 3}], 1.8)
      2.24
  """
  @spec linear_interpolation(Enum.t(), number) :: number
  def linear_interpolation(enumerable, x) when is_number(x) do
    [{x1, y1}, {x2, y2}] =
      Stream.chunk_every(enumerable, 2, 1, :discard)
      |> Stream.take_while(fn [{x0, _}, _] -> x0 < x end)
      |> Enum.reduce(Enum.slice(enumerable, 0, 2), fn data, _ -> data end)

    (y2 - y1) / (x2 - x1) * (x - x1) + y1
  end
end
