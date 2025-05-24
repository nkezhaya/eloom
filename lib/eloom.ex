defmodule Eloom do
  @moduledoc """
  Eloom does a thing.
  """

  @spec track(String.t(), map() | keyword()) :: :ok
  def track(event, properties \\ %{}) do
    __MODULE__.Events.Buffer.track(event, properties)
    :ok
  end
end
