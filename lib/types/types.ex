defmodule Bargad.Types do

    @type hash_algorithm :: :md5 | :sha | :sha224 | :sha256 | :sha384 | :sha512
    @type tree_type :: :LOG | :MAP
    @type hash :: binary
    @type backend :: [{binary,binary}, ...]
    @type values :: [binary,...]
    @type children :: [binary] | []
    @type tree_id :: non_neg_integer
    @type tree_name :: binary
    @type size :: pos_integer

    @type tree :: %Bargad.Trees.Tree{
        treeId: tree_id,
        treeType: tree_type,
        treeName: tree_name,
        hashFunction: hash_algorithm,
        root: hash,
        size: size,
        backend: backend
    }

    @type tree_node :: %Bargad.Nodes.Node{
        treeId: tree_id,
        hash: hash,
        children: children,
        size: size,
        metadata: binary
    }

    @type direction :: binary

    @type audit_proof :: [{hash, direction}, ...] | :not_found

    @type consistency_proof :: [hash, ...]

end