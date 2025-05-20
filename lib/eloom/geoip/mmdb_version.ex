defmodule Eloom.GeoIP.MMDBVersion do
  use Ecto.Schema

  import Ecto.Query
  import Eloom.Config, only: [repo: 0]

  @schema_prefix "eloom"
  schema "mmdb_versions" do
    field :version, :date
    field :data, :binary
    timestamps()
  end

  def get! do
    repo().one!(__MODULE__)
  end

  def current_version do
    from(m in __MODULE__, select: m.version)
    |> repo().one()
  end

  @spec latest() :: nil | {Date.t(), Date.t()}
  def latest do
    from(m in __MODULE__, select: {m.version, m.inserted_at})
    |> repo().one()
    |> case do
      nil -> nil
      {version, %module{} = inserted_at} -> {version, module.to_date(inserted_at)}
    end
  end

  def insert!(version, data) do
    {:ok, mmdb} =
      repo().transaction(fn ->
        mmdb =
          %__MODULE__{
            version: version,
            data: data
          }
          |> repo().insert!()

        from(m in __MODULE__, where: m.version < ^version)
        |> repo().delete_all()

        {:ok, mmdb}
      end)

    mmdb
  end
end
