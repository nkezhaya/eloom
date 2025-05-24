defmodule Eloom.Reports do
  import Ecto.Query

  alias Eloom.{Config, Event}
  alias __MODULE__.{Report, Funnel}

  defmacrop now() do
    quote do
      fragment("NOW()")
    end
  end

  defmacrop to_interval_day(days) do
    quote do
      fragment("toIntervalDay(?)", unquote(days))
    end
  end

  defmacrop to_date(timestamp) do
    quote do
      fragment("toDate(?)", unquote(timestamp))
    end
  end

  defmacrop window_funnel(window, field, args) do
    count = length(args)
    condition_params = List.duplicate("?", count) |> Enum.join(", ")
    frg = "windowFunnel(?)(?::DateTime, #{condition_params})"
    args = [field | args]
    args = [window | args]
    args = [frg | args]

    quote do
      fragment(unquote_splicing(args))
    end
  end

  def count_sessions(days) do
    {lower, upper} =
      case days do
        %Range{} = range -> {range.first, range.last}
        int when is_integer(int) -> {int, nil}
      end

    query =
      Event
      |> select([e], %{
        distinct_id: e.distinct_id,
        date: to_date(e.timestamp),
        min: min(e.timestamp)
      })
      |> where([e], e.timestamp >= now() - to_interval_day(^lower))
      |> group_by([e], [e.distinct_id, to_date(e.timestamp)])

    if upper do
      where(query, [e], e.timestamp <= now() - to_interval_day(^upper))
    else
      query
    end
    |> subquery()
    |> Config.event_repo().aggregate(:count)
  end

  def create_report(params) do
    %Report{}
    |> Report.changeset(params)
    |> Config.repo().insert()
  end

  def run_funnel(%Funnel{} = _funnel) do
    Event
    |> select([e], %{
      distinct_id: e.distinct_id,
      stage:
        window_funnel(7200, e.timestamp, [e.event == "Homepage Visit", e.event == "Page Visit"])
    })
    |> group_by([e], e.distinct_id)
    |> subquery()
    |> from()
    |> group_by([e], e.stage)
    |> select([e], %{stage: e.stage, count: count(e.stage)})
    |> Config.event_repo().all()
  end
end
