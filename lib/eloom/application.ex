defmodule Eloom.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Eloom.Config.validate!()

    children = [
      Eloom.Events.Buffer,
      {Phoenix.PubSub, name: Eloom.PubSub}
    ]

    opts = [strategy: :one_for_one, name: Eloom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
