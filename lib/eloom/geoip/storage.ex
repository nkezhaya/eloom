defmodule Eloom.GeoIP.Storage do
  use GenServer

  @table_name :eloom_geoip_storage_table

  @doc """
  Returns the metadata, tree, and data for the current MMDB database.
  """
  @spec get!() :: tuple()
  def get! do
    [{:mmdb, mmdb}] = :ets.lookup(@table_name, :mmdb)
    mmdb
  end

  @spec load_latest() :: :ok
  def load_latest do
    GenServer.call(__MODULE__, :load_latest)
  end

  ## GenServer API

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table_name, [
      :set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: false
    ])

    {:ok, %{version: nil}, {:continue, :load_latest}}
  end

  @impl true
  def handle_call(:load_latest, _, %{version: nil}) do
    {:reply, true, %{version: do_load()}}
  end

  def handle_call(:load_latest, _, %{version: local_version} = state) do
    current_version = Eloom.GeoIP.MMDBVersion.current_version()

    case Date.compare(local_version, current_version) do
      :lt ->
        {:reply, true, %{version: do_load()}}

      _ ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_continue(:load_latest, _state) do
    version =
      if Eloom.GeoIP.MMDBVersion.current_version() do
        do_load()
      end

    {:noreply, %{version: version}}
  end

  require Logger

  @spec do_load() :: Date.t()
  defp do_load do
    Logger.info("Reloading latest MMDBVersion")

    mmdb = Eloom.GeoIP.MMDBVersion.get!()

    {:ok, meta, tree, data} = MMDB2Decoder.parse_database(mmdb.data)
    :ets.insert(@table_name, [{:mmdb, {meta, tree, data}}])

    mmdb.version
  end
end
