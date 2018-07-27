defmodule Bargad do
  @moduledoc """
  Documentation for Bargad.
  """
  use Application

  def start(_type, _args) do
    Bargad.Supervisor.start_link
  end

end
