defmodule Eloom.Config do
  def flush do
    Application.get_env(:eloom, :flush, true)
  end

  def repo do
    Application.get_env(:eloom, :repo)
  end

  def geoip do
    Application.get_env(:eloom, :geoip)
  end

  def event_repo do
    Application.get_env(:eloom, :event_repo)
  end
end
