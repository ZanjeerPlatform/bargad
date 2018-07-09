defmodule Merkle do

    defstruct root: nil, hash_fn: nil, size: nil

    @type hash_fn :: :sha

    @type t :: %__MODULE__{
        root: Bargad.Node.t,
        hash_fn: hash_fn,
        size: integer()
    }

    def new() do
        %__MODULE__{
            root: nil,
            hash_fn: :sha,
            size: 0
        }
    end

    @spec build(Merkle.t, list(integer())) :: Merkle.t
    def build(tree,data) do
        Map.put(tree,:root,build(data))       
    end

    @spec build(list(integer())) :: Bargad.Node.t
    def build([x | []]) do
        %Bargad.Node{hash: :crypto.hash(:sha,to_string(x)) |> Base.encode16,
                children: nil,
                metadata: x}
    end

    @spec build(list(integer())) :: Bargad.Node.t
    def build(data) do
        n = length(data)
        k = closest_pow_2(n)
        left_child = build(Enum.slice(data,0..k-1))
        right_child = build(Enum.slice(data,k..n-1))
        %Bargad.Node{hash: :crypto.hash(:sha, left_child.hash <> right_child.hash) |> Base.encode16,
                children: [left_child, right_child],
                metadata: nil}
    end

    @spec audit_proof(Merkle.t, binary()) :: any()
    def audit_proof(tree, leaf_hash) do
        left_result  = audit_proof(tree.root, List.first(tree.root.children),leaf_hash)
        right_result = audit_proof(tree.root,List.last(tree.root.children),leaf_hash)

        case Enum.member?(left_result,:found) do 
        true -> left_result ++ [{List.last(tree.root.children).hash, "R"}]
        false -> case Enum.member?(right_result,:found) do
            true -> right_result ++ [{List.first(tree.root.children).hash, "L"}]
            _ -> right_result
            end
        end
    end

    defp audit_proof(parent, %Bargad.Node{hash: x, children: nil, metadata: _}, leaf_hash) do
        if(leaf_hash == x) do
            [:found]
        else
            [:not_found]
        end

    end

    defp audit_proof(parent,child,leaf_hash) do
        left_result = audit_proof(child,List.first(child.children),leaf_hash)
        right_result = audit_proof(child,List.last(child.children),leaf_hash)

        case Enum.member?(left_result,:found) do 
            true -> left_result ++ [{List.last(child.children).hash,"R"}]
            false -> case Enum.member?(right_result,:found) do
                true -> right_result ++ [{List.first(child.children).hash,"L"}]
                _ -> right_result
                end
            end
    end

    def hash_leaf(x) do
        :crypto.hash(:sha, to_string(x)) |> Base.encode16
    end

    def verify_audit_proof(leaf_hash,[]) do
        leaf_hash
    end

    def verify_audit_proof(leaf_hash,[{hash,direction}| t]) do
        case direction do
            "L" -> hash_leaf(hash<>leaf_hash) |> verify_audit_proof(t)
            "R" -> hash_leaf(leaf_hash<>hash) |> verify_audit_proof(t)
        end
    end

    def consistency_proof(tree,m) do
        
    end


    def get_leaves(%Bargad.Node{hash: _, children: nil, metadata: x}) do
        [x]
    end

    def get_leaves(%Bargad.Node{hash: _, children: [first, second], metadata: nil}) do
        get_leaves(first) ++ get_leaves(second)
    end



    # def insert(tree, value) do
        
    # end

    # def consistency_proof(tree) do
        
    # end

    # def audit_tree(tree) do

    # end

    # def root(tree) do
        
    # end

    def closest_pow_2(n) do
        p = :math.log2(n)
        case (:math.ceil(p) - p) do
            0.0 -> trunc(:math.pow(2,p-1))
            _ -> trunc(:math.pow(2,trunc(p)))
        end
    end
end