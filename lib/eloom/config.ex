defmodule Eloom.Config do
  def validate! do
    case Keyword.validate(all(), [:repo, :event_repo, :geoip, :flush]) do
      {:ok, _opts} -> :ok
      {:error, invalid_keys} -> raise ArgumentError, "invalid keys: #{inspect(invalid_keys)}"
    end
  end

  @compile {:inline, [all: 0, fetch!: 1]}

  @spec flush() :: boolean()
  def flush, do: fetch!(:flush, true)

  @spec repo() :: Ecto.Repo.t()
  def repo, do: fetch!(:repo)

  @spec event_repo() :: Ecto.Repo.t()
  def event_repo, do: fetch!(:event_repo)

  @spec geoip() :: keyword()
  def geoip, do: fetch!(:geoip)

  defp all, do: Application.get_all_env(:eloom)
  defp fetch!(key, default \\ nil), do: Application.get_env(:eloom, key, default)
end
