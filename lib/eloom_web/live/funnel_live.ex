defmodule EloomWeb.FunnelLive do
  use EloomWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form>
      <div class="space-y-12">
        <div class="border-b border-gray-900/10 pb-12">
          <h2 class="text-base/7 font-semibold text-gray-900 mb-2">Funnel</h2>
          <div class="px-4 sm:px-6 lg:px-8">
            <div class="sm:flex sm:items-center">
              <UI.date_range_button_group />
            </div>
          </div>
        </div>
      </div>
    </form>
    """
  end
end
