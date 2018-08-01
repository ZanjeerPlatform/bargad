# Bargad 

### Overview

Bargad is a service which implements the concepts and data strucutures described in the **Certificate Transparency** whitepaper ([RFC6962](https://tools.ietf.org/html/rfc6962 "RFC6962")) and the [**Revocation Transparency**](https://www.links.org/files/RevocationTransparency.pdf "**Revocation Transparency**") whitepaper.

The data structures mentioned above are implemented through a **Merkle tree**  which provides all the crytographic guarantees for the data.
We provide a **storage layer** for this Merkle tree which allows us to scale it for extremely large sets of data. This storage layer is flexible to accomodate many types of backends.

The Bargad service can operate in two modes
- **Log Mode** - A verifiable append only log which is filled from left to right and provides the proof for **inclusion** and **consistency** of data.

- **Map Mode** - A verifiable map which allows for the storage and retrieval of key value pairs and provides a cryptographich proof for the **inclusion** of this data.

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

### Comparison

|                           | Bargad | Trillian | Merkle Patricia Tree | Merkle Tree |
|---------------------------|--------|----------|----------------------|-------------|
| Persistence               | Yes    | Yes      | Yes                  | No          |
| Multiple Backends         | Yes    | Yes      | Yes                  | No          |
| Multiple Trees            | Yes    | Yes      | No                   | No          |
| Protocol Buffers          | Yes    | Yes      | No                   | No          |
| Verifiable Log            | Yes    | Yes      | Yes*                 | Yes*        |
| Verifiable Map            | Yes    | Yes      | No                   | No          |
| Consistency Proof for Log | Yes    | Yes      | No                   | No          |
| Inclusion Proof for Log   | Yes    | Yes      | Yes                  | Yes         |
| Inclusion Proof for Map   | Yes    | Yes      | No                   | No          |

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

    $ mix deps.get

The docs can be found at [https://hexdocs.pm/bargad](https://hexdocs.pm/bargad).

#### Usage

Bargad includes an integration test suite which covers most of the features Bargad service provides.

Nevertheless here is a basic usage of Bargad in Verifiable Log mode.

```elixir
  ## Bargad in Verifiable Log mode
 
    iex>
```


#### Integration Tests



### Contributing


### Design Overview

### Applications

- **Certificate Transparency** - Bargad in Verifiable Log mode can implement the certificate transparency protocol mentioned in RFC6962.

- **Blockchain** - Merkle trees and its derivatives form the basis of blockchains. Bargad in the Verifiable Log mode coupled with the multiple tree support can form the basis of a blockchain.

- **Distributed Databases** - Databases use Merkle trees to efficiently synchronize replicas of a database. **Riak** and **Cassandra** are using merkle trees to successfully achieve this. Bargad can do this in the Verifiable Log mode by synchronsing two tree heads, one of which would be primary and the other out of date secondary.

- **Secure and Distributed Filesystems** - **ZFS** by Oracle and  InterPlanetary File System ( **IPFS** ) and peer to peer sharing networks like **BitTorrent** use merkle trees.

### Author

Faraz Haider (@farazhaider)

### License

See the License.md file for license details.
