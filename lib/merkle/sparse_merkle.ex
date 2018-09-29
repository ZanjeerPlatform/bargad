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

defmodule SparseMerkle do

    use Bitwise
    
    # insertion in empty tree
    @spec insert(Bargad.Types.tree, binary, binary) :: Bargad.Types.tree
    def insert(tree = %Bargad.Trees.Tree{size: 0}, k, v) do
        root = Bargad.Utils.make_map_node(tree, k, v)
        Bargad.Utils.set_node(tree, root.hash, root)
        Map.put(tree, :root, root.hash) |> Map.put(:size, 1)
    end

    # insertion in non empty tree
    @spec insert(Bargad.Types.tree, binary, binary) :: Bargad.Types.tree
    def insert(tree = %Bargad.Trees.Tree{root: root, size: size}, k, v) do
        root = Bargad.Utils.get_node(tree, root)
        new_root = do_insert(tree, root, k, v)
        # basically don't delete the root if the tree contains only one node, and that would be a leaf node
        if tree.size > 1 do
        # deletes the existing root from the storage as there would be a new root
        Bargad.Utils.delete_node(tree, root.hash)
        end
        Map.put(tree, :root, new_root.hash) |> Map.put(:size, size + 1)
    end


    defp do_insert(tree, root = %Bargad.Nodes.Node{children: [left, right]}, k, v) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        l_dist = distance(k, left.key)
        r_dist = distance(k, right.key)

        # checks if the key to be inserted falls in the left subtree or the right subtree
        cond do
            l_dist == r_dist ->
                # when putting a key to a new level, we have to decide whether it will become a left child or right child
                # as distances are already equal, we find a new parameter
                # we compare the new key to the keys at this level
                # if it is smaller than max, then this new leaf will become
                # make new leaf in a new level"
                new_leaf = Bargad.Utils.make_map_node(tree, k, v)
                Bargad.Utils.set_node(tree, new_leaf.hash, new_leaf)

                min_key = min(left.key, right.key)

                if k < min_key do
                    # deletes the existing root from the storage as there would be a new root
                    Bargad.Utils.delete_node(tree, root.hash)
                    # make new leaf as left child at the new level
                    new_root = Bargad.Utils.make_map_node(tree, new_leaf, root)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
                else
                    # deletes the existing root from the storage as there would be a new root
                    Bargad.Utils.delete_node(tree, root.hash)
                    # make new leaf as right child at the new level
                    new_root = Bargad.Utils.make_map_node(tree, root, new_leaf)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
                end

            l_dist < r_dist ->
                # Going towards left child
                left = do_insert(tree, left, k, v)
                # deletes the existing root from the storage as there would be a new root
                Bargad.Utils.delete_node(tree, root.hash)
                new_root = Bargad.Utils.make_map_node(tree, left, right)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root
                
            l_dist > r_dist ->
                # Going towards right child
                right = do_insert(tree, right, k, v)
                # deletes the existing root from the storage as there would be a new root
                Bargad.Utils.delete_node(tree, root.hash)
                new_root = Bargad.Utils.make_map_node(tree, left, right)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root
        end
    end


    defp do_insert(tree, leaf = %Bargad.Nodes.Node{children: [], metadata: _, key: key}, k, v) do
        new_leaf = Bargad.Utils.make_map_node(tree, k, v)
        Bargad.Utils.set_node(tree, new_leaf.hash, new_leaf)

        # reached leaf node level

        # after reaching the level where the new key is to inserted, 
        # make a new node comprising of the existing key and new one
        # if the new leaf is bigger than the existing one, make the new one as the right child of resulting node
        cond do
            k == key -> raise "key exists"

            k > key ->
                # new key will be right child
                new_root = Bargad.Utils.make_map_node(tree, leaf , new_leaf)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root

            k < key ->
                # new key will be left child
                new_root = Bargad.Utils.make_map_node(tree, new_leaf , leaf)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root
        end
    end

    @spec get_with_inclusion_proof!(Bargad.Types.tree, binary) :: Bargad.Types.audit_proof
    def get_with_inclusion_proof!(tree = %Bargad.Trees.Tree{root: root}, k) do
        root = Bargad.Utils.get_node(tree, root)

        result = do_get_with_inclusion_proof(tree, nil, nil, root, k)

        case result do
            # membership proof case
            [{_, _} | _] -> 
                [{value, hash} | proof] = Enum.reverse(result)
                %{key: k, value: value, hash: hash, proof: proof}

            # Edge Case 1 for non-membership proof
            [key, :MINRS] -> [get_with_inclusion_proof!(tree, key), nil]

            # Edge Case 2 for non-membership proof
            [:MAXLS, key] -> [nil, get_with_inclusion_proof!(tree, key)]
    
            # When a key is bounded by two keys in case of non-membership proof
            [key1, key2] -> 
                [get_with_inclusion_proof!(tree, key1),
                get_with_inclusion_proof!(tree,key2)]
        end
    end

    # this is called only once, when starting
    defp do_get_with_inclusion_proof(tree, nil, nil, root = %Bargad.Nodes.Node{children: [left, right]}, k) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        l_dist = distance(k, left.key)
        r_dist = distance(k, right.key)

        cond do
            l_dist == r_dist ->
                case k > root.key do
                    true -> [right.key, :MINRS]
                    _ -> [:MAXLS, left.key]
                end
            l_dist < r_dist ->
                # Going towards left child
                do_get_with_inclusion_proof(tree, right, "L", left, k)
            l_dist > r_dist ->
                # Going towards right child
                do_get_with_inclusion_proof(tree, left, "R", right, k)
        end
    end

    defp do_get_with_inclusion_proof(tree, sibling, direction, leaf = %Bargad.Nodes.Node{hash: salted_hash, children: [], metadata: value, key: key}, k) do
        if key == k do
            [{sibling.hash, rev_dir(direction)}, {value, salted_hash} ]
        else
            # Find the non membership proof otherwise
            get_non_inclusion_proof({tree, k, key, direction, sibling})
            # raise "key does not exist"
        end
    end

    defp do_get_with_inclusion_proof(tree, sibling, direction, root = %Bargad.Nodes.Node{children: [left, right]}, k) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        l_dist = distance(k, left.key)
        r_dist = distance(k, right.key)

        cond do
            l_dist == r_dist ->
                # Find the non membership proof otherwise
                get_non_inclusion_proof({k, root.key, direction, sibling})

                # raise "key does not exist"
            l_dist < r_dist ->
                # Going towards left child
                result = do_get_with_inclusion_proof(tree, right, "L", left, k)

                case { result, direction } do
                    # membership proof case
                    {[{_, _} | _], _} -> [{sibling.hash, rev_dir(direction)} | result]
                    {[key, :MINRS],"L"} -> [key, min_in_subtree(tree, sibling)]
                    {[:MAXLS, key], "R"} -> [max_in_subtree(sibling), key]
                    _ -> result
                end

            l_dist > r_dist ->
                # Going towards right child
                result = do_get_with_inclusion_proof(tree, left, "R", right, k)

                case { result, direction } do
                    # membership proof case
                    {[{_, _} | _], _} -> [{sibling.hash, rev_dir(direction)} | result]
                    {[key, :MINRS],"L"} -> [key, min_in_subtree(tree, sibling)] 
                    {[:MAXLS, key], "R"} -> [max_in_subtree(sibling), key]
                    _ -> result
                end
        end
    end

    defp get_non_inclusion_proof({tree, k, key, direction, sibling}) do
        case [k > key, direction] do
            [true, "L"] ->  [key, min_in_subtree(tree, sibling)]
            [true, "R"] ->  [key, :MINRS]
            [false, "L"] -> [:MAXLS, key]
            [false, "R"] -> [max_in_subtree(sibling), key]
        end
    end

    defp min_in_subtree(tree, %Bargad.Nodes.Node{children: [left, _]}) do
        min_in_subtree(tree, Bargad.Utils.get_node(tree, left))
    end

    defp min_in_subtree(_, %Bargad.Nodes.Node{children: [], key: key}) do
        key
    end

    defp max_in_subtree(root) do
        root.key
    end

    @spec delete!(Bargad.Types.tree, binary) :: Bargad.Types.tree
    def delete!(tree = %Bargad.Trees.Tree{root: root, size: size}, k) do
        root = Bargad.Utils.get_node(tree, root)
        new_root = do_delete(tree, root, k)
        # deletes the existing root from the storage as there would be a new root
        Bargad.Utils.delete_node(tree, root.hash)
        Map.put(tree, :root, new_root.hash) |> Map.put(:size, size - 1)
    end
    
    defp do_delete(tree, root = %Bargad.Nodes.Node{children: [left, right]}, k) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        if check_for_leaf(left, right, k) do
            if left.key == k do
                # deletes the target key
                Bargad.Utils.delete_node(tree, left.hash)
                right
            else
                # deletes the target key
                Bargad.Utils.delete_node(tree, right.hash)
                left
            end
        else
            l_dist = distance(k, left.key)
            r_dist = distance(k, right.key)
            cond do
                l_dist == r_dist ->
                    raise "key does not exist"
                l_dist < r_dist ->
                    # Going towards left child
                    left = do_delete(tree, left, k)
                    # deletes the existing root from the storage as there would be a new root
                    Bargad.Utils.delete_node(tree, root.hash)
                    new_root = Bargad.Utils.make_map_node(tree, left, right)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
                l_dist > r_dist ->
                    # Going towards right child
                    right = do_delete(tree, right, k)
                    # deletes the existing root from the storage as there would be a new root
                    Bargad.Utils.delete_node(tree, root.hash)
                    new_root = Bargad.Utils.make_map_node(tree, left, right)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
            end
        end
    end

    ## Check if this would ever be called, if not then remove it.
    defp do_delete(_, leaf = %Bargad.Nodes.Node{children: [], key: key}, k) do
        if key == k do
            IO.puts "found a key here"
        else
            raise "key does not exist"
        end
    end

    defp check_for_leaf(left, right, k) do
        (left.size == 1 && left.key == k) || (right.size == 1 && right.key == k)
    end

    def audit_tree(tree) do
        root = Bargad.Utils.get_node(tree, tree.root)
        do_audit_tree(tree, root, []) |> List.flatten
    end

    defp do_audit_tree(tree, root = %Bargad.Nodes.Node{children: [left, right]}, acc) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        [do_audit_tree(tree, left, ["L" | acc])] ++
        [do_audit_tree(tree, right, ["R" | acc])]
    end

    defp do_audit_tree(_, leaf = %Bargad.Nodes.Node{children: [], metadata: m}, acc) do
        [m | acc] |> Enum.reverse |> List.to_tuple
    end

    defp distance(x, y) do
        x = x |> Base.encode16 |> Integer.parse(16) |> elem(0)
        y = y |> Base.encode16 |> Integer.parse(16) |> elem(0)

        result = bxor(x, y) 

        # xor with the same results in a zero, this check is done for when a person tries to insert an existing key
        # xor becomes 0, for which log is undefined so we return a negative value to indicated that it is the minimum distance
        if result == 0 do
            -1
        else
            result = result |> :math.log2 |> trunc
            # after log, diff was always 1 less than the actual
            result + 1
        end

    end

    defp rev_dir(dir) do
        case dir do
            "L" -> "R"
            _ -> "L"
        end
    end


end