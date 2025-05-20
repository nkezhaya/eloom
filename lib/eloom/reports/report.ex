defmodule Eloom.Reports.Report do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "eloom"
  schema "reports" do
    field :name, :string
    field :type, Ecto.Enum, values: [:funnel]
  end

  def changeset(report, attrs \\ %{}) do
    report
    |> cast(attrs, [:name, :type])
  end
end
