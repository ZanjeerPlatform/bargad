# Bargad

### Overview

Bargad is a service which implements the concepts and data strucutures described in the **Certificate Transparency** whitepaper ([RFC6962](https://tools.ietf.org/html/rfc6962 "RFC6962")) and the [**Revocation Transparency**](https://www.links.org/files/RevocationTransparency.pdf "**Revocation Transparency**") whitepaper.

The data structures mentioned above are implemented through a **Merkle tree**  which provides all the crytographic guarantees for the data.
We provide a **storage layer** for this Merkle tree which allows us to scale it for extremely large sets of data. This storage layer is flexible to accomadate many types of backends.

The Bargad service can operate in two modes
- **Log Mode** - A verifiable append only log which is filled from left to right and provides the proof for **inclusion** and **consistency** of data.

- **Map Mode** - A verifiable map which allows for the storage of key value pairs and provides a cryptographich proof for the **inclusion** of data.

### Features

#### Bargad
- Support for **mutiple backends** for persistence.
- Multi-tenanted i.e it supports **multiple tree** heads.
- Support for **multiple hashing algorithms**.
- Uses **Protocol Buffers** for efficient serialization and deserialization of data.
- Very **resilient**, recovers from crashes. Utilizes Erlang OTP constructs.

##### Verifiable Log
- Implemented as a **dense** merkle tree, filled from left to right.
- Supports generation of **consistency proofs** for the log.
- Supports **verification** of the generated consistency proofs.
- Supports generation of **inclusion proofs** for the log.
- Supports **verfication** of the generated inclusion proof.

##### Verifiable Map
- Implemented as a **sparse** merkle tree with support for storing very large amounts of data. 
- If **SHA256** is used has the hashing algorithm for the underlying merkle tree, the map can support upto **2^256 keys**.
- Supports generation of **audit/inclusion proofs** for the map.
- Supports **verfication** of the generated inclusion proof.

### Applications

- **Blockchain** - Merkle trees and its derivatives form the basis of blockchains. 

- **Distributed Databases** - Databases use Merkle trees to efficiently synchronize replicas of a database. **Riak** and **Cassandra** are using merkle trees to successfully achieve this.

- **Secure Filesystems** - **ZFS** by Oracle and  InterPlanetary File System ( **IPFS** ) and peer to peer sharing networks like **BitTorrent** use merkle trees.


### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bargad` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bargad, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bargad](https://hexdocs.pm/bargad).

