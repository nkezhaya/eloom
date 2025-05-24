defmodule EloomWeb.EventLive do
  use EloomWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:events, dom_id: &"event-#{&1.insert_id}")
     |> assign(num_entries: 0, total_entries: Eloom.Events.count_events(), end_cursor: nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, stream_events(socket, params)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold text-gray-900">Events</h1>
          <p class="mt-2 text-sm text-gray-700">
            Showing <strong>{@num_entries} results</strong> of {@total_entries} matches
          </p>
        </div>
        <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <button
            type="button"
            class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Filter
          </button>
        </div>
      </div>
      <div class="mt-8 flow-root">
        <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div class="overflow-hidden shadow-sm ring-1 ring-black/5 sm:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300">
                <thead class="bg-gray-50">
                  <tr>
                    <th
                      scope="col"
                      class="py-3.5 pr-3 pl-4 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                    >
                      Event
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      Time
                    </th>
                    <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                      User ID
                    </th>
                    <th scope="col" class="relative py-3.5 pr-4 pl-3 sm:pr-6">
                      <span class="sr-only">Edit</span>
                    </th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white" id="EventTable" phx-update="stream">
                  <tr :for={{dom_id, event} <- @streams.events} id={dom_id}>
                    <td class="py-4 pr-3 pl-4 text-sm font-medium whitespace-nowrap text-gray-900 sm:pl-6">
                      {event.event}
                    </td>
                    <td class="px-3 py-4 text-sm whitespace-nowrap text-gray-500">
                      {event.timestamp}
                    </td>
                    <td class="px-3 py-4 text-sm whitespace-nowrap text-gray-500">
                      {event.distinct_id}
                    </td>
                    <td class="relative py-4 pr-4 pl-3 text-right text-sm font-medium whitespace-nowrap sm:pr-6">
                      <a href="#" class="text-indigo-600 hover:text-indigo-900">Edit</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="flex justify-center my-8">
          <button
            :if={@end_cursor}
            type="button"
            phx-click="load_more"
            phx-value-after={@end_cursor}
            class="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 cursor-pointer"
          >
            Load more
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("load_more", params, socket) do
    {:noreply, stream_events(socket, params)}
  end

  defp stream_events(socket, params) do
    %{entries: entries, end_cursor: end_cursor} =
      Eloom.Events.paginate_events(Map.put(params, "before", socket.assigns.end_cursor))

    socket
    |> assign(:num_entries, socket.assigns.num_entries + length(entries))
    |> assign(:end_cursor, end_cursor)
    |> stream(:events, entries)
  end
end
