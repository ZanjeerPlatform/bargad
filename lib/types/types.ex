defmodule Bargad.Types do

    @type hash_algorithm :: :md5 | :sha | :sha224 | :sha256 | :sha384 | :sha512
    @type tree_type :: :LOG | :MAP
    @type backend :: [{binary,binary}, ...]
    @type values :: [binary,...]

    @type tree :: %Bargad.Trees.Tree{
        treeId: non_neg_integer,
        treeType: tree_type,
        treeName: bitstring,
        hashFunction: hash_algorithm,
        root: binary,
        size: non_neg_integer,
        backend: backend
    }

    @type tree_node :: %Bargad.Nodes.Node{
        treeId: non_neg_integer,
        hash: binary,
        children: [binary] | [],
        size: pos_integer,
        metadata: binary
    }

    @type direction :: binary

    @type audit_proof :: [{binary, direction}, ...] | :not_found

    @type consistency_proof :: [binary, ...]

end