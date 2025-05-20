defmodule Example.Repo.Migrations.InstallEloom do
  use Ecto.Migration

  def up do
    Eloom.Migrations.Postgres.V1.up()
  end

  def down do
    Eloom.Migrations.Postgres.V1.down()
  end
end
