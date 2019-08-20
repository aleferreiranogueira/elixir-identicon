defmodule Identicon do
  def main(input) do
    input |> hash_string |> seed_image |> define_color
  end

  def define_color(%Identicon.Image{color: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Puts a `hex_list` inside a seed struct in the Image module

  ## Examples
      iex> Identicon.seed_image([1,2])
      %Identicon.Image{seed: [1,2]}
  """
  def seed_image(hex_list) do
    %Identicon.Image{seed: hex_list}
  end

  @doc """
  Hashes the input string and returns a list representation

  ## Examples
      iex> Identicon.hash_string("example")
      [26, 121, 164, 214, 13, 230, 113, 142, 142, 91, 50, 110, 51, 138, 229, 51]
  """
  @spec hash_string(String.t()) :: list
  def hash_string(input) do
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list()
  end
end
