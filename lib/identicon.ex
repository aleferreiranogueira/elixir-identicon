defmodule Identicon do
  def main(input) do
    input |> hash_string
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
