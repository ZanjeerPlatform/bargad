defmodule Bargad.LogClient do
    @moduledoc """
    Client APIs for `Bargad.Log`. This module is automatically started on application start.

    The request in each API has to be of the form `t:request/0`.
    Look into the corresponding handler of each request for the exact arguments to be supplied.
    """

    use GenServer
  
    ## Client API

    @type response :: Bargad.Types.tree | Bargad.Types.audit_proof | Bargad.Types.consistency_proof | boolean 
  
    @type request :: tuple

    @doc """
    Starts the `Bargad.LogClient`.
    
    Provides an API layer for operations on `Bargad.Log`.
    """
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Creates a new `Log`.

    The event handler for this request calls `Bargad.Log.new/3` with the specified arguments.
    """
    @spec new(request) :: Bargad.Types.tree
    def new(args) do
        GenServer.call(Bargad.LogClient, {:new, args})
    end

    @doc """
    Builds a new `Log` with the provided list of values.

    The event handler for this request calls `Bargad.Log.build/4` with the specified arguments.
    """
    @spec build(request) :: Bargad.Types.tree
    def build(args) do
        GenServer.call(Bargad.LogClient, {:build, args})
    end


    @doc """
    Appends a new value into the `Log`.

    The event handler for this request calls `Bargad.Log.insert/2` with the specified arguments.
    """
    @spec append(request) :: Bargad.Types.tree
    def append(args) do
        GenServer.call(Bargad.LogClient, {:insert, args})
    end

    @doc """
    Generates an audit proof from the `Log` for the specified value.

    The event handler for this request calls `Bargad.Log.audit_proof/2` with the specified arguments.
    """
    @spec generate_audit_proof(request) :: Bargad.Types.audit_proof
    def generate_audit_proof(args) do
        GenServer.call(Bargad.LogClient, {:audit_proof, args})
    end

    @doc """
    Generates a consistency proof for the first M leaves appended in the `Log`.

    The event handler for this request calls `Bargad.Log.consistency_proof/2` with the specified arguments.
    """
    @spec generate_consistency_proof(request) :: Bargad.Types.consistency_proof
    def generate_consistency_proof(args) do
        GenServer.call(Bargad.LogClient, {:consistency_proof, args})
    end

    @doc """
    Verifies the generated consistency proof.

    The event handler for this request calls `Bargad.Log.verify_consistency_proof/3` with the specified arguments.
    """
    @spec verify_consistency_proof(request) :: boolean
    def verify_consistency_proof(args) do
        GenServer.call(Bargad.LogClient, {:verify_consistency_proof, args})
    end

    @doc """
    Verifies the generated audit proof.

    The event handler for this request calls `Bargad.Log.verify_audit_proof/3` with the specified arguments.
    """
    @spec verify_audit_proof(request) :: boolean
    def verify_audit_proof(args) do
        GenServer.call(Bargad.LogClient, {:verify_audit_proof, args})
    end
  
    ## Server Callbacks
  
    @doc false
    def init(:ok) do
      {:ok, %{}}
    end
  
    @doc false
    def handle_call({operation, args}, _from, state) do
        args = Tuple.to_list(args)
        result = apply(Bargad.Log, operation, args)
        {:reply, result, state}
    end
  
  end
  