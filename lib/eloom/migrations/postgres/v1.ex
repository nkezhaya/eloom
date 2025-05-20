defmodule Eloom.Migrations.Postgres.V1 do
  @moduledoc false

  use Ecto.Migration

  def up do
    execute("CREATE SCHEMA IF NOT EXISTS eloom")

    create table("mmdb_versions", prefix: "eloom") do
      add :version, :date
      add :data, :bytea

      timestamps()
    end

    create table("reports", prefix: "eloom", primary_key: false) do
      add :id, :uuid, null: false, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, null: false
      add :type, :string, null: false

      timestamps()
    end

    create table("reports_funnels", prefix: "eloom", primary_key: false) do
      add :id, :uuid, null: false, primary_key: true, default: fragment("gen_random_uuid()")
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :steps, :jsonb, null: false

      timestamps()
    end
  end

  def down do
    execute("DROP SCHEMA IF EXISTS eloom CASCADE")
  end
end
