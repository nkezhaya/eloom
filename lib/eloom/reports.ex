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
    |> Eloom.Config.repo().insert()
  end

  def run_funnel(%Funnel{} = funnel) do
    {_, result} =
      funnel.steps
      |> Enum.reduce({[], []}, fn step, {steps, result} ->
        steps = steps ++ [step]
        result = [distinct_count_for_steps(steps) | result]
        {steps, result}
      end)

    Enum.reverse(result)
  end

  defp distinct_count_for_steps(steps) do
    [step | tl] = steps

    query =
      from(e in Eloom.Event,
        where: e.event == ^step.event,
        select: count(e.distinct_id, :distinct)
      )

    query =
      Enum.reduce(tl, query, fn step, q ->
        from([..., e] in q,
          inner_join: e2 in Eloom.Event,
          on: e2.distinct_id == e.distinct_id,
          where: e2.timestamp > e.timestamp,
          where: e2.event == ^step.event,
          where: e2.timestamp <= datetime_add(e.timestamp, 1, "day")
        )
      end)

    Eloom.Config.event_repo().one(query)
  end
end
