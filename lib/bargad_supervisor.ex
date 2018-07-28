defmodule Bargad.Supervisor do

  @moduledoc """

  Supervisor for the `Bargad.LogClient` and  `Bargad.MapClient`.

  Started by `Bargad` on application start.
  
  """

  use Supervisor

  @doc """
    Initializes the `:dets` storage `Bargad.TreeStorage` which stores multiple tree heads. 
    Starts the supervision tree.
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link do
    # Initialize DETS for tree storage
    Bargad.TreeStorage.initialize()
    # Start Supervision Tree
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Bargad.LogClient, name: Bargad.LogClient}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
