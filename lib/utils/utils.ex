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

defmodule Bargad.Utils do

  @moduledoc """
  Utility functions required by `Merkle`, `Bargad.Log`, `Bargad.Map`.
  """

  @type tree :: Bargad.Types.tree

  @type tree_node :: Bargad.Types.tree_node

  @type tree_type :: Bargad.Types.tree_type

  @type backend :: Bargad.Types.backend

  @type hash_algorithm :: Bargad.Types.hash_algorithm

  @type hash :: Bargad.Types.hash


  @doc """
  Generates a unique TreeId for every tree.

  This TreeId is used by `Storage` and `Bargad.TreeStorage` for persisting `t:tree/0` and `t:tree_node/0`
  """
  def generate_tree_id() do
    :rand.uniform(100000)
  end

  @doc """
  Helper function to convert a Tuple List into a map.

  This is required as `Bargad.Trees` stores a map as a `List` of `Tuple`.
  """
  @spec tuple_list_to_map(tuple) :: map
  def tuple_list_to_map(tpl) do
    Enum.into(tpl, %{})
  end

  @doc """
  Creates a new tree of type `t:tree/0`. 

  Called by `Merkle.new/4` when a new `Bargad.Map` or `Bargad.Log` has to be created.
  """
  @spec make_tree(tree_type, binary, hash_algorithm, backend) :: tree
  def make_tree(tree_type, tree_name, hash_function, backend) do
    Bargad.Trees.Tree.new(
      treeId: generate_tree_id(),
      treeName: tree_name,
      treeType: tree_type,
      hashFunction: hash_function,
      root: nil,
      backend: backend
    )
  end

  @doc """
  Creates a new node in the tree of type `t:tree_node/0`. 
  """
  
  def make_node(tree, hash, children, size, metadata) do
    Bargad.Nodes.Node.new(
      treeId: tree.treeId,
      hash: hash,
      children: children,
      size: size,
      metadata: metadata
    )
  end

  @doc """
  Creates an inner node  in the tree of type `t:tree_node/0`. 
  
  Creates a new node with its children as `left` and `right`.
  """
  def make_node(tree, left, right) do
    Bargad.Utils.make_node(
      tree,
      Bargad.Utils.make_hash(tree, left.hash <> right.hash),
      [left.hash, right.hash],
      left.size + right.size,
      left.metadata <> right.metadata
    )
  end

  def make_map_node(tree, left = %Bargad.Nodes.Node{ treeId: _, hash: _, children: _, metadata: _, key: _, size: _}, right) do
    Bargad.Nodes.Node.new(
      treeId: tree.treeId,
      hash: Bargad.Utils.make_hash(tree, left.hash <> right.hash),
      children: [left.hash, right.hash],
      size: left.size + right.size,
      key: max(left.key, right.key)
    )
  end

  def make_map_node(tree, key, value) do
    # salt the node with the key to prevent storage collisions
    # eg. if two keys have the same values, their hashes would be the same and as the nodes are being
    # indexed by their keys, storage would collide. 
    # This scheme would prevent against preimage attacks as well
    Bargad.Nodes.Node.new(
      treeId: tree.treeId,
      hash: Bargad.Utils.make_hash(tree, Bargad.Utils.salt_node(key, value)),
      children: [],
      size: 1,
      metadata: value,
      key: key
    )
  end

  def salt_node(k, v) do
    k <> v
  end

  @doc """
  Hashes the binary data supplied based on the hash algorithm `t:hash_algorithm/0` specified in `t:tree`. 
  """
  def make_hash(tree, data) do
    :crypto.hash(tree.hashFunction, data) 
  end

  @doc false
  def closest_pow_2(n) do
    p = :math.log2(n)

    case :math.ceil(p) - p do
      0.0 -> trunc(:math.pow(2, p - 1))
      _ -> trunc(:math.pow(2, trunc(p)))
    end
  end

  @doc """
  Encodes `t:tree_node/0` into a `binary` using `exprotobuf`.
  """
  def encode_node(node) do
    Bargad.Nodes.Node.encode(node)
  end

  @doc """
  Decodes a `binary` into a `t:tree_node/0` using `exprotobuf`.
  """
  def decode_node(node) do
    Bargad.Nodes.Node.decode(node)
  end

  @doc """
  Encodes `t:tree/0` into a `binary` using `exprotobuf`.
  """
  def encode_tree(tree) do
    Bargad.Trees.Tree.encode(tree)
  end

  @doc """
  Decodes a `binary` into a `t:tree/0` using `exprotobuf`.
  """
  def decode_tree(tree) do
    Bargad.Trees.Tree.decode(tree)
  end

  @doc """
  Utility function for persisting a tree node.

  Calls `Storage.set_node/3`.
  """
  def set_node(tree, key, value) do
    Storage.set_node(tree.backend, key, encode_node(value))
  end

  def set_replace_node(tree, key, value) do
    Storage.set_replace_node(tree.backend, key, encode_node(value))
  end

  @doc """
  Utility function for retrieving a tree node.

  Calls `Storage.get_node/2`.
  """
  def get_node(tree, key) do
    decode_node(Storage.get_node(tree.backend, key))
  end

  def delete_node(tree, key) do
    Storage.delete_node(tree.backend, key)
  end

  @doc """
  Utility function to retrieve the backend module from `backend`.
  """
  def get_backend_module(backend) do
    backend = Bargad.Utils.tuple_list_to_map(backend)
    String.to_existing_atom("Elixir." <> backend["module"])
  end

end
