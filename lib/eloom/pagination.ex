defmodule Eloom.Pagination do
  import Ecto.Query
  alias __MODULE__.Cursor

  @type page(t) :: %{
          entries: [t],
          total_entries: non_neg_integer()
        }

  @type page() :: page(any())

  @max_page_size 50
  @spec paginate(Ecto.Queryable.t(), map(), keyword()) :: page()
  def paginate(queryable, params, opts \\ []) do
    repo = opts[:repo]
    cursor_field = opts[:cursor_field]
    total_entries = repo.aggregate(queryable, :count)

    clause =
      with last_cursor when is_binary(last_cursor) and last_cursor != "" <-
             params[:before] || params["before"],
           {:ok, last_cursor} <- Cursor.decode(last_cursor) do
        dynamic([q], field(q, ^cursor_field) < ^last_cursor)
      else
        _ -> true
      end

    entries =
      from(q in queryable, where: ^clause, limit: @max_page_size)
      |> repo.all()

    end_cursor =
      entries
      |> List.last()
      |> Map.get(cursor_field)
      |> Cursor.encode()

    %{entries: entries, total_entries: total_entries, end_cursor: end_cursor}
  end
end
