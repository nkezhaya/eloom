defmodule Eloom.Reports do
  import Ecto.Query

  alias Eloom.Config
  alias Eloom.Events.Event
  alias __MODULE__.{Report, Funnel}

  defmacrop now() do
    quote do
      fragment("now()")
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

  def count_sessions(days) do
    {lower, upper} =
      case days do
        %Range{} = range -> {range.last, range.first}
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

  def run_funnel(%Funnel{} = funnel) do
    events =
      for {_, n} <- Enum.with_index(funnel.steps) do
        "event = {$#{n}:String}"
      end
      |> Enum.join(", ")

    params = for step <- funnel.steps, do: step.event

    """
    SELECT
        funnel_stage,
        count(funnel_stage) AS user_count
    FROM
    (
        SELECT
            distinct_id,
            windowFunnel(7200)(
              CAST(timestamp, 'DateTime'),
              #{events}
            ) AS funnel_stage
        FROM events
        GROUP BY distinct_id
    ) AS results
    GROUP BY funnel_stage
    """
    |> Config.event_repo().query!(params)
  end
end
