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

defmodule Bargad do
  @moduledoc """

  ### Overview

  Bargad is a service which implements the concepts and data strucutures described in the **Certificate Transparency** whitepaper [RFC6962](https://tools.ietf.org/html/rfc6962) and the [**Revocation Transparency**](https://www.links.org/files/RevocationTransparency.pdf "**Revocation Transparency**") whitepaper.

  The data structures mentioned above are implemented through a **Merkle tree**  which provides all the crytographic guarantees for the data.
  We provide a **storage layer** for this Merkle tree which allows us to scale it for extremely large sets of data. This storage layer is flexible to accomodate many types of backends.

  The Bargad service can operate in two modes
  - **Log Mode** - A verifiable append only log which is filled from left to right and provides the proof for **inclusion** and **consistency** of data.

  - **Map Mode** - A verifiable map which allows for the storage and retrieval of key value pairs and provides a cryptographich proof for the **inclusion** of this data.

  ### Features

  The Bargad Service as a whole supports the features listed below
  - Support for **mutiple backends** for persistence.
  - Multi-tenanted i.e it supports **multiple tree** heads.
  - Support for **multiple hashing algorithms**.
  - Uses **Protocol Buffers** for efficient serialization and deserialization of data.
  - Very **resilient**, recovers from crashes. Utilizes Erlang OTP constructs.

  Features specific to different modes are given below 

  #### Verifiable Log
  - Implemented as a **dense** merkle tree, filled from left to right.
  - Supports generation of **consistency proofs** for the log.
  - Supports **verification** of the generated consistency proofs.
  - Supports generation of **inclusion proofs** for the log.
  - Supports **verfication** of the generated inclusion proof.

  #### Verifiable Map
  - Implemented as a **sparse** merkle tree with support for storing very large amounts of data. 
  - If **SHA256** is used has the hashing algorithm for the underlying merkle tree, the map can support upto **2^256 keys**.
  - Supports generation of **audit/inclusion proofs** for the map.
  - Supports **verfication** of the generated inclusion proof.

  ### Comparison

  |                                       | Bargad | Trillian | Merkle Patricia Tree | Merkle Tree |
  |---------------------------------------|--------|----------|----------------------|-------------|
  | Persistence                           | Yes    | Yes      | Yes                  | No          |
  | Multiple Backends                     | Yes    | Yes      | Yes                  | No          |
  | Multiple Trees                        | Yes    | Yes      | No                   | No          |
  | Protocol Buffers                      | Yes    | Yes      | No                   | No          |
  | Verifiable Log                        | Yes    | Yes      | Yes*                 | Yes*        |
  | Verifiable Map                        | Yes    | Yes      | No                   | No          |
  | Consistency Proof for Log             | Yes    | Yes      | No                   | No          |
  | Inclusion Proof for Log               | Yes    | Yes      | Yes                  | Yes         |
  | Inclusion/Non-Inclusion Proof for Map | Yes    | Yes      | No                   | No          |
  | Filters/Personalities                 | No     | Yes      | No                   | No          |
  | Batch writes                          | No     | Yes      | No                   | No          |
  | Second Preimage attack prevention     | Yes    | Yes      | No                   | No          |


  ### Roadmap

  -  Add Filters 
  -  Add signature to tree nodes
  -  Support for batch writes
  -  Support for LevelDB and PostgreSQL
  -  Support synchronization of two trees
  -  Provide snapshots of Map

  ### Using Bargad

  #### Installation

  Bargad is developed as an Elixir application, and is published to Hex, Elixir's package manager.
  The package can be installed to your mix project by adding `bargad` to the list of dependencies and applications in `mix.exs`:

  ```elixir
  defp deps do
  [
    {:bargad, "~> 0.1.0"}
  ]
  end
  ```

  ```elixir
  def application do
  [
    extra_applications : [ :bargad, ....]
  ]
  end
  ```

  And run:

  ```bash
   $ mix deps.get 
  ```

  The docs can be found at [https://hexdocs.pm/bargad](https://hexdocs.pm/bargad).

  #### Usage

  Bargad includes an integration test suite which covers most of the features Bargad service provides.

  Nevertheless here is a basic usage of Bargad in Verifiable Log mode.

  ```elixir
  ## Bargad in Verifiable Log mode
  ## Note that here we are directly using Bargad.Log module for simplicity, 
  ## it is recommended to use the Superwised LogClient and MapClient.

    iex> tree =
    ...> Bargad.Log.new("FRZ", :sha256, [{"module", "ETSBackend"}]) |>
    ...> Bargad.Log.insert("3") |>
    ...> Bargad.Log.insert("7")
    iex> audit_proof = Bargad.Log.audit_proof(tree, 1)
    %{
      hash: <<63, 219, 163, 95, 4, 220, 140, 70, 41, 134, 201, 146, 188, 248, 117,
        84, 98, 87, 17, 48, 114, 169, 9, 193, 98, 247, 228, 112, 229, 129, 226,
        120>>,
      proof: [
        {<<103, 6, 113, 205, 151, 64, 65, 86, 34, 110, 80, 121, 115, 242, 171, 131,
          48, 211, 2, 44, 169, 110, 12, 147, 189, 189, 179, 32, 196, 26, 220,
          175>>, "R"}
      ],
      value: "3"
    }
    iex(3)> Bargad.Log.verify_audit_proof(tree, audit_proof)
    true
    iex(2)> consistency_proof = Bargad.Log.consistency_proof(tree, 1) 
    [                                                                              
      <<63, 219, 163, 95, 4, 220, 140, 70, 41, 134, 201, 146, 188, 248, 117, 84, 98, 
       87, 17, 48, 114, 169, 9, 193, 98, 247, 228, 112, 229, 129, 226, 120>>      
    ]

  ```


  #### Integration Tests

  The integration tests can be found in the `./test/bargad_test.exs` file and can be run with the `mix test`
  command.

  ### Contributing

  1. [Fork it!](https://github.com/ZanjeerPlatform/bargad/fork)
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request


  ### Applications

  - **Certificate Transparency** - Bargad in Verifiable Log mode can implement the certificate transparency protocol mentioned in RFC6962.

  - **Blockchain** - Merkle trees and its derivatives form the basis of blockchains. Bargad in the Verifiable Log mode coupled with the multiple tree support can form the basis of a blockchain.

  - **Distributed Databases** - Databases use Merkle trees to efficiently synchronize replicas of a database. **Riak** and **Cassandra** are using merkle trees to successfully achieve this. Bargad can do this in the Verifiable Log mode by synchronsing two tree heads, one of which would be primary and the other out of date secondary.

  - **Secure and Distributed Filesystems** - **ZFS** by Oracle and  InterPlanetary File System ( **IPFS** ) and peer to peer sharing networks like **BitTorrent** use merkle trees.

  ### Author

  Faraz Haider (@farazhaider)

  ### License

  See the license.md file for license details.

  """
  use Application

  @doc false
  def start(_type, _args) do
    Bargad.Supervisor.start_link()
  end
end
