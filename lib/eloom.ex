defmodule Eloom do
  @moduledoc """
  Eloom does a thing.
  """

  import Ecto.Query
  alias __MODULE__.{Config, Event, Pagination}

  @spec track(String.t(), map() | keyword()) :: :ok
  def track(event, properties \\ %{}) do
    __MODULE__.EventBuffer.track(event, properties)
    :ok
  end

  @spec paginate_events(map()) :: Repo.page(Event.t())
  def paginate_events(params \\ %{}) do
    Event
    |> order_by(desc: :timestamp)
    |> Pagination.paginate(params, repo: Config.event_repo(), cursor_field: :timestamp)
  end

  def count_events do
    Config.event_repo().aggregate(Event, :count)
  end

  def count_sessions(days) do
    Event
    |> where([e], e.timestamp > fragment("now() - interval '90 days'"))
    |> Config.event_repo().aggregate(:count)
  end
end
