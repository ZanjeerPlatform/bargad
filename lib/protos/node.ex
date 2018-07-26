defmodule Bargad.Nodes do
    @external_resource Path.expand("./node.proto", __DIR__)

    use Protobuf, from: Path.expand("./node.proto", __DIR__)   
end