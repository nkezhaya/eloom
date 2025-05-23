defmodule EloomWeb.LiveHelpers do
  def number_to_delimited(number) do
    number
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.reduce([], fn
      [a, b, c], acc -> acc ++ [a, b, c, ?,]
      chunk, acc -> acc ++ chunk
    end)
    |> Enum.reverse()
    |> case do
      [?, | tl] -> tl
      num -> num
    end
    |> to_string()
  end
end
