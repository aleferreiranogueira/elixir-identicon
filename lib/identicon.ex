defmodule Identicon do
  def main(input) do
    input
    |> hash_string
    |> define_color
    |> build_grid
    |> build_pixel_map
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_value, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        {horizontal, vertical}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def build_grid(%Identicon.Image{seed: seed} = image) do
    incomplete_rows = Enum.chunk_every(seed, 3)

    grid =
      List.delete_at(incomplete_rows, length(incomplete_rows) - 1)
      |> Enum.map(fn [first, second | _tail] = row -> row ++ [second, first] end)
      |> List.flatten()
      |> Enum.with_index()
      |> Enum.filter(fn {value, _index} -> rem(value, 2) == 0 end)

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Picks the first three elements of the `seed` struct and puts as a tuple in the color struct representing RGB values

  ## Examples

      iex> Identicon.define_color(%Identicon.Image{seed: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51]})
      %Identicon.Image{seed: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51]color: {26, 121, 164}}

  """
  def define_color(%Identicon.Image{seed: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Hashes the input string as a list and puts it in a `seed` struct in the Image module

  ## Examples

      iex> Identicon.hash_string("example")
      %Identicon.Image{seed: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51]}

  """
  @spec hash_string(String.t()) :: struct
  def hash_string(input) do
    hex_list =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{seed: hex_list}
  end
end
