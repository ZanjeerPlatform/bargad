# Copyright 2018 Faraz Haider. All Rights Reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule SparseMerkle do

    use Bitwise

    # metadata field can be used to store the max in a subtree


    defp distance(x, y) do
        x = x |> Base.encode16 |> Integer.parse(16) |> elem(0)
        y = y |> Base.encode16 |> Integer.parse(16) |> elem(0)

        result = bxor(x, y) 

        # xor with the same results in a zero, this check is done for when a person tries to insert an existing key
        # xor becomes 0, for which log is undefined so we return a negative value to indicated that it is the minimum distance
        if result == 0 do
            -1
        else
            result |> :math.log2 |> trunc
        end

    end

    
    # insertion in empty tree
    def insert(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: _, size: 0, hashFunction: _}, k, v) do
        root = Bargad.Utils.make_map_node(tree, k, v)
        Bargad.Utils.set_node(tree, root.hash, root)
        Map.put(tree, :root, root.hash) |> Map.put(:size, 1)
    end

    # insertion in non empty tree
    def insert(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: root, size: size, hashFunction: _}, k, v) do
        root = Bargad.Utils.get_node(tree, root)
        root = insert(tree, root, k, v)
        Map.put(tree, :root, root.hash) |> Map.put(:size, size + 1)
    end


    defp insert(tree, root = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [left, right], metadata: _, key: _, size: _}, k, v) do
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
                IO.puts "Putting new leaf in a new level"
                new_leaf = Bargad.Utils.make_map_node(tree, k, v)
                Bargad.Utils.set_node(tree, new_leaf.hash, new_leaf)

                min_key = min(left.key, right.key)
                max_key = max(left.key, right.key)

                if k < min_key do
                    # make new leaf as left child at the new level
                    new_root = Bargad.Utils.make_map_node(tree, new_leaf, root)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
                else
                    # make new leaf as right child at the new level
                    new_root = Bargad.Utils.make_map_node(tree, root, new_leaf)
                    Bargad.Utils.set_node(tree, new_root.hash, new_root)
                    new_root
                end

            l_dist < r_dist ->
                # Going towards left child
                left = insert(tree, left, k, v)
                new_root = Bargad.Utils.make_map_node(tree, left, right)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root
                
            l_dist > r_dist ->
                # Going towards right child
                left = insert(tree, right, k, v)
                new_root = Bargad.Utils.make_map_node(tree, left, right)
                Bargad.Utils.set_node(tree, new_root.hash, new_root)
                new_root
        end
    end


    defp insert(tree, leaf = %Bargad.Nodes.Node{ treeId: _, hash: _, children: [], metadata: _, key: key, size: _}, k, v) do
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

    def get_with_inclusion_proof!(tree = %Bargad.Trees.Tree{treeId: _, treeType: _, backend: _, treeName: _, root: root, size: size, hashFunction: _}, k) do
        root = Bargad.Utils.get_node(tree, root)
        get_with_inclusion_proof(tree, nil, nil, root, k) |> Enum.reverse
    end

    defp get_with_inclusion_proof(tree, nil, nil, root = %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [left, right], metadata: _, key: _, size: _}, k) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        l_dist = distance(k, left.key)
        r_dist = distance(k, right.key)

        cond do
            l_dist == r_dist ->
                raise "key does not exist"
            l_dist < r_dist ->
                # Going towards left child
                get_with_inclusion_proof(tree, right, "R", left, k)
            l_dist > r_dist ->
                # Going towards right child
                get_with_inclusion_proof(tree, left, "L", right, k)
        end
    end

    defp get_with_inclusion_proof(tree, sibling, direction, leaf = %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [], metadata: _, key: key, size: _}, k) do
        if key == k do
            [{sibling.hash, direction}]
        else
            raise "key does not exist"
        end
    end

    defp get_with_inclusion_proof(tree, sibling, direction, root = %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [left, right], metadata: _, key: _, size: _}, k) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        l_dist = distance(k, left.key)
        r_dist = distance(k, right.key)

        cond do
            l_dist == r_dist ->
                raise "key does not exist"
            l_dist < r_dist ->
                # Going towards left child
                [{sibling.hash, direction} | get_with_inclusion_proof(tree, right, "R", left, k)]
            l_dist > r_dist ->
                # Going towards right child
                [{sibling.hash, direction} | get_with_inclusion_proof(tree, left, "L", right, k)]
        end
    end


    def audit_tree(tree) do
        root = Bargad.Utils.get_node(tree, tree.root)
        audit_tree(tree, root, [])
    end

    defp audit_tree(tree, root = %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [left, right], metadata: _, key: _, size: _}, acc) do
        left = Bargad.Utils.get_node(tree, left)
        right = Bargad.Utils.get_node(tree, right)

        audit_tree(tree, left, ["L" | acc])
        audit_tree(tree, right, ["R" | acc])
    end

    defp audit_tree(tree, leaf = %Bargad.Nodes.Node{ treeId: _, hash: hash, children: [], metadata: m, key: key, size: _}, acc) do
        IO.inspect Enum.reverse([m | acc])
    end

end