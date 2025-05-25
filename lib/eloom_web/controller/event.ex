defmodule EloomWeb.EventController do
  @moduledoc false
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    with %{"event" => event, "properties" => properties} when is_map(properties) <- conn.params do
      Eloom.track(event, properties)
    end

    conn
    |> put_resp_header("content-type", "application/json")
    |> put_private(:plug_skip_csrf_protection, true)
    |> send_resp(200, "{}")
    |> halt()
  end
end
