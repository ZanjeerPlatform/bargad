defmodule Bargad.Utils do
  def generate_tree_id() do
    1
  end

  def tuple_list_to_map(tpl) do
    Enum.into(tpl, %{})
  end

  def make_tree(tree_type, tree_name, hash_function, backend) do
    Bargad.Trees.Tree.new(
      treeId: generate_tree_id(),
      treeName: tree_name,
      treeType: tree_type,
      hashFunction: hash_function,
      root: nil,
      backend: backend
    )
  end

  def make_node(tree, hash, children, size, metadata) do
    Bargad.Nodes.Node.new(
      treeId: tree.treeId,
      hash: hash,
      children: children,
      size: size,
      metadata: metadata
    )
  end

  def make_node(tree, left, right) do
    Bargad.Utils.make_node(
      tree,
      Bargad.Utils.make_hash(tree, left.hash <> right.hash),
      [left.hash, right.hash],
      left.size + right.size,
      left.metadata <> right.metadata
    )
  end

  def make_hash(tree, data) do
    :crypto.hash(tree.hashFunction, data) |> Base.encode16()
  end

  def closest_pow_2(n) do
    p = :math.log2(n)

    case :math.ceil(p) - p do
      0.0 -> trunc(:math.pow(2, p - 1))
      _ -> trunc(:math.pow(2, trunc(p)))
    end
  end

  def encode_node(node) do
    Bargad.Nodes.Node.encode(node)
  end

  def decode_node(node) do
    Bargad.Nodes.Node.decode(node)
  end

  def encode_tree(tree) do
    Bargad.Trees.Tree.encode(tree)
  end

  def decode_tree(tree) do
    Bargad.Trees.Tree.decode(tree)
  end

  def set_node(tree, key, value) do
    Storage.set_node(tuple_list_to_map(tree.backend), key, encode_node(value))
  end

  def get_node(tree, key) do
    decode_node(Storage.get_node(tuple_list_to_map(tree.backend), key))
  end

  def get_backend_module(backend) do
    backend = Bargad.Utils.tuple_list_to_map(backend)
    String.to_existing_atom("Elixir." <> backend["module"])
  end

end
