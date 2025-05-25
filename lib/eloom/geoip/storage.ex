defmodule Eloom.GeoIP.Storage do
  @moduledoc """
  A GenServer for managing and caching the MaxMind GeoIP database (MMDB).

  This server maintains the latest version of the MMDB in an ETS table for fast,
  concurrent lookups. It automatically loads the most recent MMDB data, ensures
  data consistency, and provides fast, thread-safe access to geolocation data.
  """
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

  @doc """
  Loads the latest available MMDB database version into ETS storage.

  Returns `true` if a new version was loaded, or `false` if already up-to-date.
  """
  @spec load_latest() :: boolean()
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
