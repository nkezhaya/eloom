defmodule Eloom.Pagination.Cursor do
  @spec encode(map()) :: binary()
  def encode(key) do
    Base.url_encode64(:erlang.term_to_binary(key, minor_version: 2))
  end

  @spec decode(binary()) :: {:ok, map()} | :error
  def decode(cursor) do
    with {:ok, binary} <- Base.url_decode64(cursor),
         {:ok, term} <- safe_binary_to_term(binary) do
      sanitize(term)

      if is_map(term) && term |> Map.keys() |> Enum.all?(&is_atom/1),
        do: {:ok, term},
        else: :error
    end
  rescue
    _e in RuntimeError -> :error
  end

  defp safe_binary_to_term(term) do
    {:ok, :erlang.binary_to_term(term, [:safe])}
  rescue
    _e in ArgumentError -> :error
  end

  defp sanitize(term)
       when is_atom(term) or is_number(term) or is_binary(term) do
    term
  end

  defp sanitize([]), do: []
  defp sanitize([h | t]), do: [sanitize(h) | sanitize(t)]

  defp sanitize(%{} = term) do
    :maps.fold(
      fn key, value, acc ->
        sanitize(key)
        sanitize(value)
        acc
      end,
      term,
      term
    )
  end

  defp sanitize(term) when is_tuple(term) do
    term
    |> Tuple.to_list()
    |> sanitize()
  end

  defp sanitize(_) do
    raise "invalid cursor value"
  end
end
