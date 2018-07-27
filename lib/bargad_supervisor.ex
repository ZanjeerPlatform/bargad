defmodule Bargad.Supervisor do
  use Supervisor

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
