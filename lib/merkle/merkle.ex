defmodule Merkle do

  @spec new(Bargad.Types.tree_type, binary, Bargad.Types.hash_algorithm, Bargad.Types.backend) :: Bargad.Types.tree
  def new(tree_type, tree_name, hash_function, backend) do
    tree = Bargad.Utils.make_tree(tree_type, tree_name, hash_function, backend)
    tree = Bargad.Utils.get_backend_module(backend).init_backend(tree)
    # put an empty leaf to make hash not nil (proto def says it's required), make the size zero
    Map.put(tree, :root, Bargad.Utils.make_hash(tree,<<>>)) |> Map.put(:size, 0)
  end

  @spec build(Bargad.Types.tree, Bargad.Types.values) :: Bargad.Types.tree
  def build(tree, data) do
    # See this https://elixirforum.com/t/transform-a-list-into-an-map-with-indexes-using-enum-module/1523
    # Doing this to associate each value with it's insertion point.
    data = 1..length(data) |> Enum.zip(data) |> Enum.into([])
    Map.put(tree, :root, build(tree, data, 0).hash) |> Map.put(:size, length(data))
  end

  defp build(tree, [ {index, value} | []], _) do
    node = Bargad.Utils.make_node(tree, Bargad.Utils.make_hash(tree, index |> Integer.to_string |> Bargad.Utils.salt_node(value)), [], 1, value)
    Bargad.Utils.set_node(tree,node.hash,node)
    node
  end

  defp build(tree, data, _) do
    n = length(data)
    k = Bargad.Utils.closest_pow_2(n)
    left_child = build(tree, Enum.slice(data, 0..(k - 1)), 0)
    right_child = build(tree, Enum.slice(data, k..(n - 1)), 0)

    node = Bargad.Utils.make_node(
      tree,
      Bargad.Utils.make_hash(tree,left_child.hash <> right_child.hash),
      [left_child.hash, right_child.hash],
      left_child.size + right_child.size,
      left_child.metadata <> right_child.metadata
    )

    Bargad.Utils.set_node(tree,node.hash,node)
    node
  end

  use Bitwise

  def audit_proof(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: root, size: 1, hashFunction: _}, m) do
    root = Bargad.Utils.get_node(tree, root)
    if m == 1 do
      %{value: root.metadata, proof: []}
    else
      raise "value out of range"
    end
  end

  def audit_proof(tree, m) do
    #check left and right subtree, go wherever the value is closer
    if m > tree.size || m <= 0 do
      raise "value not in range"
    else
    root = Bargad.Utils.get_node(tree, tree.root)
    result = audit_proof(tree, nil, nil, root, m) |> Enum.reverse
    %{value: hd(result), proof: tl(result)}
    end
  end

  defp audit_proof(tree, nil, nil, root = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [left , right], metadata: _, size: size}, m) do
    l = :math.ceil(:math.log2(size)) |> trunc

    left =  Bargad.Utils.get_node(tree,left)
    right = Bargad.Utils.get_node(tree,right)

    if m <= (1 <<< (l-1)) do
      audit_proof(tree, right, "R", left, m)
    else
      audit_proof(tree, left, "L", right, m - (1 <<< (l-1)))
    end
  end

  defp audit_proof(tree, sibling, direction, root = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [left , right], metadata: _, size: size}, m) do
    l = :math.ceil(:math.log2(size)) |> trunc

    left =  Bargad.Utils.get_node(tree,left)
    right = Bargad.Utils.get_node(tree,right)

    if m <= (1 <<< (l-1)) do
      [{sibling.hash, direction} | audit_proof(tree, right, "R", left, m)]
    else
      [{sibling.hash, direction} | audit_proof(tree, left, "L", right, m - (1 <<< (l-1)))]
    end

  end

  defp audit_proof(tree, sibling, direction, leaf = %Bargad.Nodes.Node{treeId: _, hash: x, children: [], metadata: value, size: _}, m) do
    [{sibling.hash, direction}, value ]
  end

  defp verify_audit_proof(leaf_hash, [], _, _) do
    leaf_hash
  end

  @spec verify_audit_proof(binary, Bargad.Types.audit_proof, Bargad.Types.tree, term) :: binary
  defp verify_audit_proof(leaf_hash, [{hash, direction} | t], tree, _) do
    case direction do
      "L" -> Bargad.Utils.make_hash(tree, hash <> leaf_hash) |> verify_audit_proof(t, tree,0)
      "R" -> Bargad.Utils.make_hash(tree, leaf_hash <> hash) |> verify_audit_proof(t, tree,0)
    end
  end

  @spec verify_audit_proof(Bargad.Types.tree, Bargad.Types.audit_proof, binary) :: boolean
  def verify_audit_proof(tree, proof, leaf_hash) do
    if( tree.root == verify_audit_proof(leaf_hash, proof, tree,0)) do
      true
    else 
      false
    end
  end

  @spec consistency_proof(Bargad.Types.tree, pos_integer) :: Bargad.Types.consistency_proof
  def consistency_proof(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: root,  size: _, hashFunction: _}, m) do
    root = Bargad.Utils.get_node(tree, root)
    l = :math.ceil(:math.log2(root.size))
    t = trunc(:math.log2(m))
    consistency_proof(tree, nil, root, {l, t, m, root.size})
  end 

  defp consistency_proof(_, _, {_, _, 0, _}) do
    []
  end

  defp consistency_proof(_, _, %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [], metadata: _, size: _}, _) do
    [hash]
  end

  defp consistency_proof(tree, sibling, %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [_ , _], metadata: _, size: _}, {l, t, m, _}) when l==t do
    size = trunc(:math.pow(2,l))
    m = m - trunc(:math.pow(2,l))
    case m do
      0 -> [hash]
      _ -> l = :math.ceil(:math.log2(size))
      t = trunc(:math.log2(m))
      [ hash | consistency_proof(tree, nil, sibling, {l, t, m, size})]
    end
    
  end

  defp consistency_proof(tree, _, %Bargad.Nodes.Node{ treeId: _, hash: _, children: [left , right], metadata: _, size: _}, {l, t, m, size}) do 
    left = Bargad.Utils.get_node(tree,left)
    right = Bargad.Utils.get_node(tree,right)
    consistency_proof(tree, right, left, {l-1, t, m, size})
  end

  defp verify_consistency_proof([]) do
    
  end

  defp verify_consistency_proof(tree, [first, second]) do
    Bargad.Utils.make_hash(tree, first<>second)
  end

  @spec verify_consistency_proof(Bargad.Types.tree, Bargad.Types.consistency_proof) :: binary
  defp verify_consistency_proof(tree, [head | tail]) do
    Bargad.Utils.make_hash(tree, head <> verify_consistency_proof(tree,tail))
  end
 
  @spec verify_consistency_proof(Bargad.Types.tree, Bargad.Types.consistency_proof, binary) :: binary
  def verify_consistency_proof(tree, proof, old_root_hash) do
    hash = verify_consistency_proof(tree, proof)
    if (hash == old_root_hash) do
      true
    else false
    end
  end

  defp insert(tree, parent, left = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [], metadata: _, size: _}, _, _, "L")  do
    right = Bargad.Utils.get_node(tree, List.last(parent.children))
    node = Bargad.Utils.make_node(tree, left, right)
    Bargad.Utils.set_node(tree,node.hash,node)
    node
  end

  defp insert(tree, _, left = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [], metadata: _, size: _}, x, _, "R")  do
    right = Bargad.Utils.make_node(tree, Bargad.Utils.make_hash(tree, tree.size + 1 |> Integer.to_string |> Bargad.Utils.salt_node(x)), [], 1, x)
    Bargad.Utils.set_node(tree,right.hash,right)
    node = Bargad.Utils.make_node(tree, left, right)
    Bargad.Utils.set_node(tree,node.hash,node)
    node
  end

  defp insert(tree, _, root = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [left, right], metadata: _, size: _}, x, l, _)  do
    left = Bargad.Utils.get_node(tree, left)
    right = Bargad.Utils.get_node(tree, right)
    if left.size < :math.pow(2,l-1) do
      left = insert(tree, root, left, x, l-1,"L")
      right = Bargad.Utils.make_node(tree, Bargad.Utils.make_hash(tree, tree.size + 1 |> Integer.to_string |> Bargad.Utils.salt_node(x)), [], 1, x)
      Bargad.Utils.set_node(tree,right.hash,right)
    else
      right = insert(tree, root, right, x, l-1,"R")
    end

    # deletes the existing root from the storage as there would be a new root
    Bargad.Utils.delete_node(tree, root.hash)

    node = Bargad.Utils.make_node(tree, left, right)
    Bargad.Utils.set_node(tree,node.hash,node)
    node
  end


  def insert(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: _, size: 0, hashFunction: _}, x) do
    node = Bargad.Utils.make_node(tree, Bargad.Utils.make_hash(tree, tree.size + 1 |> Integer.to_string |> Bargad.Utils.salt_node(x)), [], 1, x)
    Bargad.Utils.set_node(tree, node.hash, node)
    Map.put(tree, :root, node.hash) |> Map.put(:size, 1)
  end

  @spec insert(Bargad.Types.tree, binary) :: Bargad.Types.tree
  def insert(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: root,  size: size, hashFunction: _}, x) do
    root = Bargad.Utils.get_node(tree, root)
    l = :math.ceil(:math.log2(root.size))
    
    if root.size == :math.pow(2,l) do
      right = Bargad.Utils.make_node(tree, Bargad.Utils.make_hash(tree, tree.size + 1 |> Integer.to_string |> Bargad.Utils.salt_node(x)), [], 1, x)
      Bargad.Utils.set_node(tree, right.hash, right)
      # basically don't delete the root if the tree contains only one node, and that would be a leaf node
      if tree.size > 1 do
        # deletes the existing root from the storage as there would be a new root
        Bargad.Utils.delete_node(tree, root.hash)
      end
      root = Bargad.Utils.make_node(tree, root, right)
      Bargad.Utils.set_node(tree,root.hash,root)
      Map.put(tree, :root, root.hash) |> Map.put(:size, size + 1)
    else
      [left, right] = root.children
      left = Bargad.Utils.get_node(tree, left)
      right = Bargad.Utils.get_node(tree, right)
      if left.size < :math.pow(2,l-1) do
        left = insert(tree, root, left, x, l-1,"L")
      else
        right = insert(tree, root, right, x, l-1,"R" )
      end
      # deletes the existing root from the storage as there would be a new root
      Bargad.Utils.delete_node(tree, root.hash)
      root = Bargad.Utils.make_node(tree, left, right)
      Bargad.Utils.set_node(tree,root.hash,root)
      Map.put(tree, :root, root.hash) |> Map.put(:size, size + 1)
    end
  end

end
