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

defmodule Bargad.Log do

    @moduledoc """
    An append-only Log mode, backed by an underlying merkle tree.
    Once an entry has been accepted by the Log it cannot be changed or removed.
    In this mode, the Merkle tree is filled up from the left, giving a dense Merkle tree.
    Log mode has support for  generation and verification of Consistency and Audit Proofs.
    """

    
    def new(tree_name, hash_function, backend) do
        tree = Bargad.Merkle.new(:LOG, tree_name, hash_function, backend)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def build(tree_name, hash_function, backend, values) do
        tree = new(tree_name, hash_function, backend) |> Bargad.Merkle.build(values)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def insert(log, value) do
        tree = Bargad.Merkle.insert(log, value)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def consistency_proof(log, m) do
        Bargad.Merkle.consistency_proof(log, m)
    end

    def audit_proof(log, m) do
        Bargad.Merkle.audit_proof(log, m)
    end

    def verify_consistency_proof(log, proof, old_root_hash) do
        Bargad.Merkle.verify_consistency_proof(log, proof, old_root_hash)
    end

    def verify_audit_proof(log, proof) do
        Bargad.Merkle.verify_audit_proof(log, proof)
    end

    def load_log(log_id) do
        Bargad.TreeStorage.load_tree(log_id)
    end

    def delete_log(log_id) do
        Bargad.TreeStorage.delete_tree(log_id)
    end


    
end