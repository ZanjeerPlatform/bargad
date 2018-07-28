defmodule ETSBackend do
    @behaviour Storage

    def init_backend(tree) do
        nodes_table = String.to_atom(Integer.to_string(tree.treeId) <> "_" <> "nodes")
        :ets.new(nodes_table, [:set, :protected, :named_table])
        backend = tree.backend ++ [{"nodes_table",Atom.to_string(nodes_table)}]
        Map.put(tree, :backend, backend)
    end

    def get_node(backend, key) do
       backend = Bargad.Utils.tuple_list_to_map(backend)
       [{_, value}]  = :ets.lookup(String.to_existing_atom(backend["nodes_table"]), key)
       value
    end

    def set_node(backend, key, value) do
        backend = Bargad.Utils.tuple_list_to_map(backend)
        :ets.insert_new(String.to_existing_atom(backend["nodes_table"]), {key, value})
    end

end