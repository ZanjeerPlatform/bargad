defmodule Bargad.Log do

    def new(tree_name, hash_function, backend) do
        tree = Merkle.new(:LOG, tree_name, hash_function, backend)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def build(tree_name, hash_function, backend, values) do
        tree = new(tree_name, hash_function, backend) |> Merkle.build(values)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def insert(log, value) do
        tree = Merkle.insert(log, value)
        Bargad.TreeStorage.save_tree(tree.treeId, Bargad.Utils.encode_tree(tree))
        tree
    end

    def consistency_proof(log, m) do
        Merkle.consistency_proof(log, m)
    end

    def audit_proof(log, value) do
        Merkle.audit_proof(log, value)
    end

    def verify_consistency_proof(log, proof, old_root_hash) do
        Merkle.verify_consistency_proof(log, proof, old_root_hash)
    end

    def verify_audit_proof(log,proof,value) do
        Merkle.verify_audit_proof(log,proof,value)
    end
    
end