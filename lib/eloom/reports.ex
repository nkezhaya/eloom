defmodule Eloom.Reports do
  import Ecto.Query

  alias __MODULE__.{Report, Funnel}

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
