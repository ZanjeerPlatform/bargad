defmodule Bargad.Log do

    def new() do
        Merkle.new()
    end

    def build(values) do
        Merkle.new() |> Merkle.build(values)
    end

    def insert(log, value) do
        Merkle.insert(log, value)
    end

    def consistency_proof(log, m) do
        Merkle.consistency_Proof(log, m)
    end

    def audit_proof(log, value) do
        Merkle.audit_proof(log, value)
    end

    def verify_consistency_proof(log, proof, old_root_hash) do
        Merkle.verify_consistency_proof(proof,old_root_hash)
    end

    def verify_audit_proof(log,proof,value) do
        Merkle.verify_audit_proof(log,proof,value)
    end
    
end