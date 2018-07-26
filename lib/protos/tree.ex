defmodule Bargad.Trees do
    @external_resource Path.expand("./tree.proto", __DIR__)
    use Protobuf, from: Path.expand("./tree.proto", __DIR__)
end