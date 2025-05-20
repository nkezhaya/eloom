defmodule Eloom.GeoIP do
  alias __MODULE__.Storage

  def lookup(ip) do
    ip = parse_ip(ip)
    {meta, tree, data} = Storage.get!()
    MMDB2Decoder.lookup(ip, meta, tree, data)
  end

  defp parse_ip(ip) when is_tuple(ip), do: ip

  defp parse_ip(ip) do
    {:ok, ip} = :inet.parse_address(String.to_charlist(ip))
    ip
  end
end
