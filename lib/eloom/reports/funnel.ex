defmodule Eloom.Reports.Funnel do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "eloom"
  schema "reports" do
    field :start_date, :date
    field :end_date, :date

    embeds_many :steps, Step do
      field :event, :string
    end
  end

  def changeset(report, attrs \\ %{}) do
    report
    |> cast(attrs, [:start_date, :end_date])
    |> cast_embed(:steps)
  end
end
