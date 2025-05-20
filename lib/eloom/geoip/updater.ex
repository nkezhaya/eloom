defmodule Eloom.GeoIP.Updater do
  use GenServer

  alias Eloom.GeoIP.{MMDBVersion, Client, Storage}

  def update do
    case Client.download_db() do
      {:ok, {date, tar}} ->
        update_from_tar(date, tar)
        Storage.load_latest()
        :ok

      error ->
        error
    end
  end

  defp update_from_tar(version, tar) do
    {:ok, files} = :erl_tar.extract({:binary, tar}, [:compressed, :memory])

    data =
      Enum.find_value(files, fn {file, data} ->
        if String.ends_with?(to_string(file), ".mmdb"), do: data
      end)

    MMDBVersion.insert!(version, data)
  end

  ## GenServer API

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_after()

    {:ok, nil}
  end

  @impl true
  def handle_info(:update, state) do
    # TODO: Might be better to switch to an advisory lock or something

    ref = make_ref()

    :global.trans({:eloom_geoip_update, ref}, fn ->
      maybe_update()
    end)

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp maybe_update do
    case MMDBVersion.latest() do
      {current_version, date_inserted} ->
        two_days_ago = Date.add(Date.utc_today(), -2)

        if Date.compare(date_inserted, two_days_ago) == :lt do
          case Client.fetch_last_modified() do
            {:ok, last_modified} ->
              if Date.compare(current_version, last_modified) == :lt do
                update_and_schedule()
              end

            {:error, :too_many_requests} ->
              schedule_after(:timer.hours(12))

            {:error, _} ->
              schedule_after(:timer.minutes(5))
          end
        end

      _ ->
        update_and_schedule()
    end
  end

  defp update_and_schedule do
    update()

    schedule_after(:timer.hours(24))
  end

  defp schedule_after(time \\ :rand.uniform(2_000) + 2_000) do
    Process.send_after(__MODULE__, :update, time)
  end
end
