defmodule Storage do
    @moduledoc """
    Defines a general key-value storage for persisting and retrieval of the Merkle Tree Nodes `t:Bargad.Types.tree_node/0`.
    The tree nodes can be a part of either `Bargad.Log` or `Bargad.Map`. 
    We define a callback that can be implemented by a number of potential backends.
    """

    @callback init_backend(term) :: term
    @callback set_node(term,term,term) :: term
    @callback get_node(term,term) :: term



    @doc """
    Persists a node with the specified key, value in the given backend.
    """
    def set_node(backend,key,value) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.set_node(backend,key,value)
    end


    @doc """
    Retrieves a node with the specified key from the given backend.
    """
    def get_node(backend,key) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.get_node(backend,key)
    end

end