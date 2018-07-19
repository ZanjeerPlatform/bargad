defmodule Merkle do
  defstruct root: nil, hash_fn: nil, size: nil

  @type hash_fn :: :sha

  @type t :: %__MODULE__{
          root: Bargad.Node.t(),
          hash_fn: hash_fn,
          size: integer()
        }

  def new() do
    %__MODULE__{
      root: nil,
      hash_fn: :sha,
      size: 0
    }
  end

  @spec build(Merkle.t(), list(integer())) :: Merkle.t()
  def build(tree, data) do
    %Merkle{root: build(data), hash_fn: tree.hash_fn, size: length(data)}
  end

  @spec build(list(integer())) :: Bargad.Node.t()
  def build([x | []]) do
    %Bargad.Node{
      hash: :crypto.hash(:sha, to_string(x)) |> Base.encode16(),
      children: nil,
      metadata: x
    }
  end

  @spec build(list(integer())) :: Bargad.Node.t()
  def build(data) do
    n = length(data)
    k = closest_pow_2(n)
    left_child = build(Enum.slice(data, 0..(k - 1)))
    right_child = build(Enum.slice(data, k..(n - 1)))

    %Bargad.Node{
      hash: :crypto.hash(:sha, left_child.hash <> right_child.hash) |> Base.encode16(),
      children: [left_child, right_child],
      metadata: to_string(left_child.metadata) <> "-" <> to_string(right_child.metadata)
    }
  end

  @spec audit_proof(Merkle.t(), binary()) :: any()
  def audit_proof(tree, leaf_hash) do
    left_result = audit_proof(tree.root, List.first(tree.root.children), leaf_hash)
    right_result = audit_proof(tree.root, List.last(tree.root.children), leaf_hash)

    case Enum.member?(left_result, :found) do
      true ->
        left_result ++ [{List.last(tree.root.children).hash, "R"}]

      false ->
        case Enum.member?(right_result, :found) do
          true -> right_result ++ [{List.first(tree.root.children).hash, "L"}]
          _ -> right_result
        end
    end
  end

  defp audit_proof(parent, %Bargad.Node{hash: x, children: nil, metadata: _}, leaf_hash) do
    if leaf_hash == x do
      [:found]
    else
      [:not_found]
    end
  end

  defp audit_proof(parent, child, leaf_hash) do
    left_result = audit_proof(child, List.first(child.children), leaf_hash)
    right_result = audit_proof(child, List.last(child.children), leaf_hash)

    case Enum.member?(left_result, :found) do
      true ->
        left_result ++ [{List.last(child.children).hash, "R"}]

      false ->
        case Enum.member?(right_result, :found) do
          true -> right_result ++ [{List.first(child.children).hash, "L"}]
          _ -> right_result
        end
    end
  end

  def hash_leaf(x) do
    :crypto.hash(:sha, to_string(x)) |> Base.encode16()
  end

  def verify_audit_proof(leaf_hash, []) do
    leaf_hash
  end

  def verify_audit_proof(leaf_hash, [{hash, direction} | t]) do
    case direction do
      "L" -> hash_leaf(hash <> leaf_hash) |> verify_audit_proof(t)
      "R" -> hash_leaf(leaf_hash <> hash) |> verify_audit_proof(t)
    end
  end

  defp audit_tree(%Bargad.Node{hash: x, children: nil, metadata: y}, _) do
    IO.puts x <> " || " <> to_string(y)
  end

  defp audit_tree(%Bargad.Node{hash: x, children: [left,right], metadata: y}, _) do
      IO.puts x <> " || " <> y
      audit_tree(left,0)
      audit_tree(right,0)
  end

  def audit_tree(tree) do
    audit_tree(tree.root,0)
  end


  def closest_pow_2(n) do
    p = :math.log2(n)

    case :math.ceil(p) - p do
      0.0 -> trunc(:math.pow(2, p - 1))
      _ -> trunc(:math.pow(2, trunc(p)))
    end
  end

  def consistency_Proof(%Merkle{root: root, hash_fn: _, size: size}, m) do
    l = :math.ceil(:math.log2(size))
    t = trunc(:math.log2(m))
    consistency_Proof(nil, root, {l, t, m, size})
  end 

  def consistency_Proof(_, {_, _, 0, _}) do
    []
  end

  def consistency_Proof(sibling, %Bargad.Node{ hash: hash, children: nil, metadata: _}, _) do
    [hash]
  end

  def consistency_Proof(sibling, %Bargad.Node{ hash: hash, children: [left , right], metadata: _}, {l, t, m, size}) when l==t do
    size = trunc(:math.pow(2,l))
    m = m - trunc(:math.pow(2,l))
    l = :math.ceil(:math.log2(size))
    t = trunc(:math.log2(m))
    [ hash | consistency_Proof(nil, sibling, {l, t, m, size})]
  end

  def consistency_Proof(sibling, %Bargad.Node{ hash: _, children: [left , right], metadata: _}, {l, t, m, size}) do
      consistency_Proof(right, left, {l-1, t, m, size})
  end


  def verify_consistency_proof([]) do
    
  end

  def verify_consistency_proof([first, second]) do
    :crypto.hash(:sha, first <> second) |> Base.encode16()
  end

  def verify_consistency_proof([head | tail]) do
    :crypto.hash(:sha, head <> verify_consistency_proof(tail)) |> Base.encode16()
  end

end
