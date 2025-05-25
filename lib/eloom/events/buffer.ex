defmodule Eloom.Events.Buffer do
  @moduledoc """
  A buffered event tracking GenServer for efficiently batching and inserting
  analytics events into the database.

  Events are temporarily stored in an ETS table, indexed by a monotonically
  increasing atomic counter. Events are periodically flushed to the database in
  configurable chunks, ensuring optimal write performance.
  """

  use GenServer

  @table_name :eloom_event_buffer_table
  @counter_name :eloom_event_buffer_counter
  @flush_ms 2_000
  @flush_chunk_size 10_000

  @doc """
  Tracks a new event, assigning it a unique insert ID and timestamp if not provided.
  """
  @spec track(String.t(), map()) :: :ok
  def track(event, properties) do
    insert_id =
      case properties["$insert_id"] do
        nil -> Ecto.UUID.generate()
        insert_id -> insert_id
      end

    properties =
      Map.put_new_lazy(properties, "timestamp", fn -> System.system_time(:microsecond) end)

    counter = :atomics.add_get(counter_ref(), 1, 1)
    :ets.insert(@table_name, {counter, insert_id, event, properties})

    :ok
  end

  @doc """
  Synchronously flushes all buffered events to persistent storage.
  """
  @spec flush() :: :ok
  def flush do
    GenServer.call(__MODULE__, :flush, :infinity)
  end

  defp counter_ref do
    :persistent_term.get(@counter_name)
  end

  ## GenServer API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table_name, [
      :ordered_set,
      :public,
      :named_table,
      read_concurrency: false,
      write_concurrency: true
    ])

    ref = :atomics.new(1, signed: false)
    :persistent_term.put(@counter_name, ref)

    schedule_work()

    {:ok, nil}
  end

  @impl true
  def handle_call(:flush, _from, state) do
    do_flush()

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:flush, state) do
    if Eloom.Config.flush() do
      do_flush()
    end

    schedule_work()

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    if Eloom.Config.flush() do
      do_flush()
    end
  end

  defp do_flush do
    counter = :atomics.get(counter_ref(), 1)
    do_flush(counter)
    :ets.select_delete(@table_name, [{{:"$1", :_, :_, :_}, [{:"=<", :"$1", counter}], [true]}])
  end

  defp do_flush(counter) do
    result =
      :ets.select(
        @table_name,
        [{{:"$1", :"$2", :"$3", :"$4"}, [{:"=<", :"$1", counter}], [{{:"$2", :"$3", :"$4"}}]}],
        @flush_chunk_size
      )

    do_flush(counter, result)
  end

  defp do_flush(_, :"$end_of_table") do
    :ok
  end

  defp do_flush(counter, {events, continuation}) do
    insert_events(events)

    result = :ets.select(continuation)
    do_flush(counter, result)
  end

  defp insert_events(events) do
    entries =
      for {insert_id, event, properties} <- events do
        {timestamp, properties} = Map.pop!(properties, "timestamp")
        {distinct_id, properties} = Map.pop(properties, "distinct_id")

        timestamp =
          case timestamp do
            int when is_integer(int) ->
              case DateTime.from_unix(int, :microsecond) do
                {:ok, dt} -> dt
                _ -> DateTime.from_unix(int, :microsecond)
              end

            %DateTime{} ->
              timestamp
          end

        %{
          insert_id: insert_id,
          event: event,
          timestamp: timestamp,
          distinct_id: distinct_id,
          properties: Jason.encode!(properties)
        }
      end

    Eloom.Config.event_repo().insert_all(Eloom.Events.Event, entries)
  end

  defp schedule_work,
    do: Process.send_after(__MODULE__, :flush, @flush_ms)
end
