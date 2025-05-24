defmodule Eloom.Events do
  import Ecto.Query

  alias Eloom.{Config, Pagination}
  alias __MODULE__.Event

  @spec paginate_events(map()) :: Repo.page(Event.t())
  def paginate_events(params \\ %{}) do
    Event
    |> order_by(desc: :timestamp)
    |> Pagination.paginate(params, repo: Config.event_repo(), cursor_field: :timestamp)
  end

  def count_events do
    Config.event_repo().aggregate(Event, :count)
  end
end
