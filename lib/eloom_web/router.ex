defmodule EloomWeb.Router do
  defmacro eloom(path) do
    quote bind_quoted: binding() do
      @eloom_prefix Phoenix.Router.scoped_path(__MODULE__, path) |> String.replace_suffix("/", "")
      def __eloom_prefix__, do: @eloom_prefix

      scope path, alias: false, as: false do
        import Phoenix.Router, only: [get: 4, post: 4]

        live_session :eloom,
          root_layout: {EloomWeb.Layouts, :root},
          on_mount: [{EloomWeb.LiveHooks, :global}] do
          live "/", EloomWeb.HomeLive, :index
          live "/events", EloomWeb.EventLive, :index
          live "/funnels", EloomWeb.FunnelLive, :index
        end

        get "/css-:hash", EloomWeb.AssetController, :css, as: :eloom_asset
        get "/js-:hash", EloomWeb.AssetController, :js, as: :eloom_asset
        post "/api/events", EloomWeb.EventController, :create, as: :eloom_event
      end
    end
  end
end
