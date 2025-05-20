defmodule Eloom.Migrations.Ch.V1 do
  @moduledoc false

  use Ecto.Migration

  def up do
    execute("""
    CREATE TABLE events (
        event LowCardinality(String),
        distinct_id String,
        insert_id String,
        timestamp DateTime64(3, 'UTC'),
        properties String
    ) ENGINE = MergeTree()
    ORDER BY (event, timestamp)
    PARTITION BY toYYYYMM(timestamp)
    SETTINGS index_granularity = 8192
    """)
  end

  def down do
    execute("DROP TABLE events")
  end
end
