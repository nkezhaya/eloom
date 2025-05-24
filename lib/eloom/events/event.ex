defmodule Eloom.Events.Event do
  use Ecto.Schema

  @primary_key false
  schema "events" do
    field :event, Ch, type: "LowCardinality(String)"
    field :distinct_id, :string
    field :insert_id, :string
    field :timestamp, Ch, type: "DateTime64(3, 'UTC')"
    field :properties, :string
  end

  @type t() :: %__MODULE__{}
end
