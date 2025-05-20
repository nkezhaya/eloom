defmodule EloomWeb.FunnelLive do
  use EloomWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <UI.date_range_button_group />
      </div>
    </div>
    """
  end
end
