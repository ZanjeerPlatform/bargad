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

defmodule Bargad.TreeStorage do
    @moduledoc """
    Implements a `:dets` key value storage for persisting tree heads.
    This enables `Bargad` to support multiple trees.
    """

    @doc """

    Initializes `:dets` with a table `:tree_table`.
    
    The table is created if it does not exist.
    """
    def initialize() do
        :dets.open_file(:tree_table, [type: :set])
    end

    @doc """
    Saves a tree with the specified key in `:dets`.
    """
    def save_tree(key, value) do
        :dets.insert(:tree_table, {key, value})
    end

    @doc """
    Retrives a tree with the specified key from `:dets`.
    """
    def load_tree(key) do
        :dets.lookup(:tree_table, key)
    end

    @doc """
    Deletes a tree with the specified key from `:dets`.
    """
    def delete_tree(key) do
        :dets.delete(:tree_table, key)
    end
    
end