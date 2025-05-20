defmodule Example.EventRepo do
  use Ecto.Repo,
    otp_app: :example,
    adapter: Ecto.Adapters.ClickHouse
end
