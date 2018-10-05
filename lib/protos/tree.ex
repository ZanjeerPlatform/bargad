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

defmodule Bargad.Trees do
    @moduledoc """
    Protobuf definition for a tree
    ```
    message Tree {

        enum TreeType {
        LOG = 1;
        MAP = 2;
        }

        enum HashFunction {
            md5 = 1;  
            sha = 2;
            sha224 = 3;
            sha256 = 4;
            sha384 = 5;
            sha512 = 6;
        }

        required bytes treeId = 1;
        required TreeType treeType = 2;
        required HashFunction hashFunction = 3;
        required bytes root = 4;
        required int64 size = 5;
        map<string,string> backend = 6;
        optional string treeName = 7;
    }
    ```
    """
    @doc false
    @external_resource Path.expand("./tree.proto", __DIR__)
    use Protobuf, from: Path.expand("./tree.proto", __DIR__)
end