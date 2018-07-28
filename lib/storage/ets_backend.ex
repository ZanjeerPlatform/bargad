defmodule ETSBackend do
    @moduledoc """
    Implementation of `Storage` behaviour which is backed by `:ets`.
    """
    @behaviour Storage

    @doc """
    Initializes the `:ets`. 

    Creates a new table in the form of `treeId_nodes` and stores this information in the `backend` field of the tree.
    """
    def init_backend(tree) do
        nodes_table = String.to_atom(Integer.to_string(tree.treeId) <> "_" <> "nodes")
        :ets.new(nodes_table, [:set, :protected, :named_table])
        backend = tree.backend ++ [{"nodes_table",Atom.to_string(nodes_table)}]
        Map.put(tree, :backend, backend)
    end

    @doc """
    Retrieves a node with the specified key from `:ets`.
    """
    def get_node(backend, key) do
       backend = Bargad.Utils.tuple_list_to_map(backend)
       [{_, value}]  = :ets.lookup(String.to_existing_atom(backend["nodes_table"]), key)
       value
    end

    @doc """
    Persists a node in `:ets` with the specified key, value.
    """
    def set_node(backend, key, value) do
        backend = Bargad.Utils.tuple_list_to_map(backend)
        :ets.insert_new(String.to_existing_atom(backend["nodes_table"]), {key, value})
    end

end