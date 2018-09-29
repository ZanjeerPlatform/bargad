# Copyright 2018 Faraz Haider. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
        nodes_table = String.to_atom("nodes" <> "_" <> tree.treeId)
        :ets.new(nodes_table, [:set, :public, :named_table])
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

    def delete_node(backend, key) do
        backend = Bargad.Utils.tuple_list_to_map(backend)
        :ets.delete(String.to_existing_atom(backend["nodes_table"]), key)
     end

    @doc """
    Persists a node in `:ets` with the specified key, value.
    """
    def set_node(backend, key, value) do
        backend = Bargad.Utils.tuple_list_to_map(backend)
        :ets.insert_new(String.to_existing_atom(backend["nodes_table"]), {key, value})
    end

end