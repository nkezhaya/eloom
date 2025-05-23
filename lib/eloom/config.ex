defmodule Eloom.Config do
  defstruct flush: true, repo: nil, event_repo: nil, geoip: []

  @type t() :: %__MODULE__{
          flush: boolean(),
          repo: Ecto.Repo.t(),
          event_repo: Ecto.Repo.t(),
          geoip: keyword()
        }

  def new(opts) do
    case Keyword.validate(opts, [:repo, :event_repo, :geoip, flush: true]) do
      {:ok, opts} -> struct!(__MODULE__, opts)
      {:error, invalid_keys} -> raise ArgumentError, "invalid keys: #{inspect(invalid_keys)}"
    end
  end
end
