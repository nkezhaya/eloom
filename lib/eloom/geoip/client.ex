defmodule Eloom.GeoIP.Client do
  @moduledoc """
  HTTP client module responsible for interacting with MaxMind's GeoIP database
  service.

  Handles fetching the latest modification date, downloading the GeoIP MMDB
  database, and managing HTTP redirects. This module uses Erlang's built-in
  `:httpc` for HTTP requests.

  ## Configuration

  Configuration is read from the application environment via `Eloom.Config.geoip/0`, requiring:

    - `account_id`: Your MaxMind account ID
    - `license_key`: Your MaxMind license key
    - `edition`: The MMDB database edition (e.g., "GeoLite2-City")
  """

  require Logger

  @doc """
  Fetches the last modification date of the MMDB file from MaxMind.

  Returns `{:ok, Date.t()}` if successful, otherwise an error tuple.
  """
  def fetch_last_modified do
    Logger.debug("Fetching last modified date...")

    case request(:head, build_url()) do
      {:ok, _status, headers, _response} ->
        {:ok, get_date_from_headers(headers)}

      {:error, _} = error ->
        error
    end
  end

  def download_db do
    Logger.debug("Downloading latest MMDB...")

    case request(:get, build_url()) do
      {:ok, status, headers, _body} when status in 301..302 ->
        location = header_value(headers, "location")

        case request(:get, location, body_format: :binary) do
          {:ok, 200, headers, body} ->
            date = get_date_from_headers(headers)
            {:ok, {date, body}}

          {:error, _} = error ->
            error
        end

      {:error, _} = error ->
        error
    end
  end

  defp request(method, url, opts \\ []) do
    case :httpc.request(method, {url, []}, [autoredirect: false], opts) do
      {:ok, {{_, status, _}, headers, body}} ->
        case status do
          status when status in 200..302 ->
            {:ok, status, headers, body}

          429 ->
            {:error, :too_many_requests}

          _ ->
            {:error, status, headers, body}
        end

      {:error, _} = error ->
        error
    end
  end

  @doc false
  def build_url do
    geoip = Eloom.Config.geoip()
    account_id = geoip[:account_id]
    license_key = geoip[:license_key]
    edition = geoip[:edition]

    "https://#{account_id}:#{license_key}@download.maxmind.com/geoip/databases/#{edition}/download?suffix=tar.gz"
  end

  defp header_value(headers, header) do
    header = to_charlist(header)

    Enum.find_value(headers, fn
      {^header, val} -> to_string(val)
      _ -> nil
    end)
  end

  defp get_date_from_headers(headers) do
    headers
    |> header_value("content-disposition")
    |> get_date_from_filename()
  end

  defp get_date_from_filename(filename) do
    filename
    |> to_string()
    |> String.split(:binary.compile_pattern(["_", ".tar.gz"]), trim: true)
    |> List.last()
    |> parse_date()
  end

  # Converts a "YYYYMMDD" string into a Date struct.
  defp parse_date(<<year::binary-size(4), month::binary-size(2), day::binary-size(2)>>) do
    Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day))
  end
end
