defmodule EloomWeb.HomeLive do
  use EloomWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>home</p>
    """
  end
end
