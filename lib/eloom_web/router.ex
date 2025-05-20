defmodule EloomWeb.Router do
  defmacro eloom(path) do
    quote bind_quoted: binding() do
      @eloom_prefix Phoenix.Router.scoped_path(__MODULE__, path) |> String.replace_suffix("/", "")
      def __eloom_prefix__, do: @eloom_prefix

      scope path, alias: false, as: false do
        import Phoenix.Router, only: [get: 4]

        live_session :eloom,
          root_layout: {EloomWeb.Layouts, :root},
          on_mount: [{EloomWeb.LiveHooks, :global}] do
          get "/css-:hash", EloomWeb.AssetsPlug, :css, as: :eloom_asset
          get "/js-:hash", EloomWeb.AssetsPlug, :js, as: :eloom_asset

          live "/", EloomWeb.HomeLive, :index
          live "/events", EloomWeb.EventLive, :index
          live "/funnels", EloomWeb.FunnelLive, :index
        end
      end
    end
  end
end
