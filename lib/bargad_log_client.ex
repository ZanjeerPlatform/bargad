defmodule Bargad.LogClient do
    use GenServer
  
    ## Client API
  
    @doc """
    Starts the registry.
    """
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end
  
    @doc """
    Looks up the bucket pid for `name` stored in `server`.
  
    Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
    """
    def new(args) do
        GenServer.call(Bargad.LogClient, {:new, args})
    end

    def build(args) do
        GenServer.call(Bargad.LogClient, {:build, args})
    end

    def insert(args) do
        GenServer.call(Bargad.LogClient, {:insert, args})
    end

    def generate_audit_proof(args) do
        GenServer.call(Bargad.LogClient, {:audit_proof, args})
    end

    def generate_consistency_proof(args) do
        GenServer.call(Bargad.LogClient, {:consistency_proof, args})
    end

    def verify_consistency_proof(args) do
        GenServer.call(Bargad.LogClient, {:verify_consistency_proof, args})
    end

    def verify_audit_proof(args) do
        GenServer.call(Bargad.LogClient, {:verify_audit_proof, args})
    end
  
    ## Server Callbacks
  
    def init(:ok) do
      {:ok, %{}}
    end
  
    def handle_call({operation, args}, _from, state) do
        args = Tuple.to_list(args)
        result = apply(Bargad.Log, operation, args)
        {:reply, result, state}
    end
  
  end
  