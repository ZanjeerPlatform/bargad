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