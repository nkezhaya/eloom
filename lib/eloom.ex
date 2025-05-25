defmodule Eloom do
  @moduledoc """
  Eloom does a thing.
  """

  @spec track(String.t(), map()) :: :ok
  defdelegate track(event, properties), to: __MODULE__.Events.Buffer
end
