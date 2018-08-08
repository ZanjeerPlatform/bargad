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

defmodule Storage do
    @moduledoc """
    Defines a general key-value storage for persisting and retrieval of the Merkle Tree Nodes `t:Bargad.Types.tree_node/0`.
    The tree nodes can be a part of either `Bargad.Log` or `Bargad.Map`. 
    We define a callback that can be implemented by a number of potential backends.
    """

    @callback init_backend(term) :: term
    @callback set_node(term,term,term) :: term
    @callback set_replace_node(term,term,term) :: term
    @callback get_node(term,term) :: term
    @callback delete_node(term,term) :: term



    @doc """
    Persists a node with the specified key, value in the given backend.
    """
    def set_node(backend,key,value) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.set_node(backend,key,value)
    end

    def set_replace_node(backend,key,value) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.set_replace_node(backend,key,value)
    end


    @doc """
    Retrieves a node with the specified key from the given backend.
    """
    def get_node(backend,key) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.get_node(backend,key)
    end

    def delete_node(backend,key) do
        backend_module = Bargad.Utils.get_backend_module(backend)
        backend_module.delete_node(backend,key)
    end

end