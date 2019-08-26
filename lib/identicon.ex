defmodule Identicon do
  @spec main(String.t()) :: :ok | {:error, atom}
  def main(input) do
    input
    |> hash_string
    |> define_color
    |> build_grid
    |> build_pixel_map
    |> generate_image
    |> save_image(input)
  end

  @doc """
  Persists a binary Identicon to disk

  ## Examples
      iex> Identicon.hash_string("xpto") |> Identicon.define_color |> Identicon.build_grid |> Identicon.build_pixel_map |> Identicon.generate_image |> Identicon.save_image("xpto")
      :ok

  """
  @spec save_image(binary, String.t()) :: :ok | {:error, atom}
  def save_image(file, input) do
    File.write("#{input}.png", file)
  end

  @doc """
  Generates a Identicon image and returns the binary
  """
  @spec generate_image(%Identicon.Image{}) :: binary
  def generate_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
    file = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {x, y} ->
      :egd.filledRectangle(file, {x, y}, {x + 50, y + 50}, fill)
    end)

    :egd.render(file)
  end

  @doc """
  Returns a `pixel_map` struct representing x and y values to be drawn in the image.

  ## Examples

      %Identicon.Image{
      color: {56, 81, 177},
      grid: [{56, 0},{56, 4},{174, 5},{202, 7},{174, 9},{12, 10},{166, 11},{166, 13},{12, 14},{194, 15},{74, 16},{2, 17},{74, 18},{194, 19},{86, 20},{168, 21},{10, 22},{168, 23},{86, 24}],
      pixel_map: [{0, 0},{200, 0},{0, 50},{100, 50},{200, 50},{0, 100},{50, 100},{150, 100},{200, 100},{0, 150},{50, 150},{100, 150},{150, 150},{200, 150},{0, 200},{50, 200},{100, 200},{150, 200},{200, 200}],
      seed: [56, 81, 177, 174, 115, 202, 12, 166, 227, 194, 74, 2, 86, 168, 10, 206]
      }
  """
  @spec build_pixel_map(%Identicon.Image{}) :: %Identicon.Image{}
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_value, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        {horizontal, vertical}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Generates a grid struct with only the even values in a tuple with it's index

  ## Examples

      iex> Identicon.hash_string("xpto") |> Identicon.define_color |> Identicon.build_grid
      %Identicon.Image{
        color: {56, 81, 177},
        grid: [{56, 0},{56, 4},{174, 5},{202, 7},{174, 9},{12, 10},{166, 11},{166, 13},{12, 14},{194, 15},{74, 16},{2, 17},{74, 18},{194, 19},{86, 20},{168, 21},{10, 22},{168, 23},{86, 24}],
        pixel_map: nil,
        seed: [56, 81, 177, 174, 115, 202, 12, 166, 227, 194, 74, 2, 86, 168, 10, 206]
      }

  """
  @spec build_grid(%Identicon.Image{}) :: %Identicon.Image{}
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
      %Identicon.Image{seed: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51],
      color: {26, 121, 164}}

  """
  @spec define_color(%Identicon.Image{seed: list}) :: %Identicon.Image{seed: list, color: tuple}
  def define_color(%Identicon.Image{seed: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Hashes the input string as a list and puts it in a `seed` struct in the Image module

  ## Examples

      iex> Identicon.hash_string("example")
      %Identicon.Image{seed: [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51]}

  """
  @spec hash_string(String.t()) :: %Identicon.Image{seed: list}
  def hash_string(input) do
    hex_list =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{seed: hex_list}
  end
end
