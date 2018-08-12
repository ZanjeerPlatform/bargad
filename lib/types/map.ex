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

defmodule Bargad.Map do

    def new(tree_name, hash_function, backend) do
        tree = Merkle.new(:MAP, tree_name, hash_function, backend)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def set(map, key, value) do
        map = SparseMerkle.insert(map, key, value)
        Bargad.TreeStorage.save_tree(map.treeId, Bargad.Utils.encode_tree(map))
        map
        # node will store the key hash, the value of the that key will go in metdata for now
        # the map would store the the tree root, total levels, size, each node would store the leaves below it
    end

    def get(map, key) do
        SparseMerkle.get_with_inclusion_proof!(map, key)
        ## ADD CACHING to speed up get process
    end

    def verify_inclusion_proof(map, proof, value) do
        leaf_hash = Bargad.Utils.make_hash(map, value)
        Merkle.verify_audit_proof(map, proof, leaf_hash)
    end

    def delete(map, key) do
        map = SparseMerkle.delete!(map, key)
        Bargad.TreeStorage.save_tree(map.treeId, Bargad.Utils.encode_tree(map))
        map
    end

    def load_map(map_id) do
        Bargad.TreeStorage.load_tree(map_id)
    end

    def delete_map(map_id) do
        Bargad.TreeStorage.delete_tree(map_id)
    end


end