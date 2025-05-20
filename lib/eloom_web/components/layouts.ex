defmodule EloomWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use EloomWeb, :controller` and
  `use EloomWeb, :live_view`.
  """
  use EloomWeb, :html

  embed_templates "layouts/*"

  def asset_path(conn, asset) do
    hash = EloomWeb.AssetsPlug.current_hash(asset)
    prefix = conn.private.phoenix_router.__eloom_prefix__()

    Phoenix.VerifiedRoutes.unverified_path(
      conn,
      conn.private.phoenix_router,
      "#{prefix}/#{asset}-#{hash}"
    )
  end

  def nav_item(assigns) do
    prefix = assigns.router.__eloom_prefix__()
    assigns = assign(assigns, :href, "#{prefix}#{assigns.href}")
    active? = assigns.current_path == assigns.href
    class = ["group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold"]

    class =
      if active? do
        ["bg-gray-50 text-indigo-600" | class]
      else
        ["text-gray-700 hover:text-indigo-600 hover:bg-gray-50" | class]
      end

    icon_class = "size-6 shrink-0 "

    icon_class =
      if active? do
        "#{icon_class} text-indigo-600"
      else
        "#{icon_class} text-gray-400 hover:text-indigo-600"
      end

    assigns =
      assigns
      |> assign(:class, class)
      |> assign(:icon_class, icon_class)

    ~H"""
    <li>
      <a href={@href} class={@class}>
        {render_slot(@inner_block, @icon_class)}
      </a>
    </li>
    """
  end
end
