defmodule Example.EventRepo.Migrations.InstallEloom do
  use Ecto.Migration

  def up do
    Eloom.Migrations.Ch.V1.up()
  end

  def down do
    Eloom.Migrations.Ch.V1.down()
  end
end
