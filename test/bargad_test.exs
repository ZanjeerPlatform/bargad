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

defmodule BargadTest do
  use ExUnit.Case

  doctest Bargad


  
  @empty <<227, 176, 196, 66, 152, 252, 28, 20, 154, 251, 244, 200, 153, 111, 185, 36,
  39, 174, 65, 228, 100, 155, 147, 76, 164, 149, 153, 27, 120, 82, 184, 85>>

  ## Hashes h1 to h7 i.e leaf node hashes are salted by their insertion point, 
  ## here it is assumed that 1 was inserted first, 2 was second etc.
  ## So h1 contains that hash for "1" <> "1" and so on.

  @h1 <<79, 200, 43, 38, 174, 203, 71, 210, 134, 140, 78, 251, 227, 88, 23, 50, 163, 231, 203, 204, 
  108, 46, 251, 50, 6, 44, 8, 23, 10, 5, 238, 184>>

  @h2 <<120, 95, 62, 199, 235, 50, 243, 11, 144, 205, 15, 207, 54, 87, 211, 136, 181, 255, 66, 151,
  242, 249, 113, 111, 246, 110, 155, 105, 192, 93, 221, 9>>
 
  @h3 <<198, 243, 172, 87, 148, 74, 83, 20, 144, 205, 57, 144, 45, 15, 119, 119, 21, 253, 0, 94, 250, 
  201, 163, 6, 34, 213, 245, 32, 94, 127, 104, 148>>

  @h4 <<113, 238, 69, 163, 192, 219, 154, 152, 101, 247, 49, 61, 211, 55, 44, 246, 13, 202, 100, 121, 
  212, 98, 97, 243, 84, 46, 185, 52, 110, 74, 4, 214>>

  @h5 <<2, 210, 11, 189, 126, 57, 74, 213, 153, 154, 76, 235, 171, 172, 150, 25, 115, 44, 52, 58, 76, 
  172, 153, 71, 12, 3, 226, 59, 162, 189, 194, 188>>

  @h6 <<58, 218, 146, 242, 139, 76, 237, 163, 133, 98, 235, 240, 71, 198, 255, 5, 64, 13, 76, 87, 35, 
  82, 161, 20, 46, 237, 254, 246, 125, 33, 230, 98>>

  @h7 <<168, 138, 121, 2, 203, 78, 246, 151, 186, 11, 103, 89, 197, 14, 140, 16, 41, 127, 245, 143, 148, 
  34, 67, 222, 25, 185, 132, 132, 27, 254, 31, 115>>

  @h1_2 <<174, 86, 139, 96, 80, 100, 130, 199, 152, 102, 211, 202, 127, 141, 229, 228,
  191, 185, 30, 105, 131, 222, 113, 100, 114, 4, 121, 158, 229, 142, 185, 72>>

  @h1_2_3 <<125, 209, 10, 138, 85, 10, 170, 3, 224, 79, 22, 19, 250, 235, 85, 39, 217,
  224, 186, 33, 217, 197, 209, 167, 75, 48, 141, 226, 118, 150, 18, 62>>

  @h3_4 <<120, 213, 172, 148, 218, 5, 101, 242, 224, 78, 182, 5, 161, 152, 97, 82, 199,
  15, 60, 164, 19, 229, 105, 233, 212, 162, 44, 200, 239, 12, 206, 225>>

  @h5_6 <<247, 225, 45, 249, 249, 223, 203, 198, 148, 111, 111, 250, 249, 184, 229, 213,
  5, 20, 116, 162, 22, 151, 66, 105, 210, 15, 237, 79, 115, 55, 33, 176>>

  @h5_6_7 <<40, 183, 127, 132, 211, 107, 207, 84, 141, 186, 156, 142, 224, 165, 1, 224,
  179, 133, 156, 122, 251, 43, 135, 16, 5, 119, 233, 246, 172, 118, 195, 182>>

  @h1_2_3_4 <<85, 25, 163, 48, 38, 226, 23, 127, 100, 13, 250, 134, 253, 214, 216, 120, 224,
  106, 110, 97, 47, 60, 126, 232, 189, 221, 232, 181, 110, 17, 220, 213>>

  @h1_2_3_4_5_6 <<30, 217, 107, 107, 135, 64, 147, 94, 26, 33, 112, 206, 151, 172, 209, 217,
  158, 191, 32, 235, 75, 76, 158, 194, 212, 155, 187, 170, 66, 175, 231, 6>>

  @h1_2_3_4_5_6_7 <<242, 197, 53, 19, 5, 23, 59, 126, 216, 253, 60, 14, 220, 187, 235, 206, 193,
  104, 171, 235, 234, 162, 59, 47, 40, 81, 108, 128, 53, 229, 27, 132>>

  @k0 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>

  @k1 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1>>

  @k2 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2>>

  @k3 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3>>

  @k4 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4>>
  
  @k5 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5>>
  
  @k6 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6>>
  
  @k7 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7>>
  
  @k8 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8>>

  @k10 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10>>

  @k63 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 63>>

  @k254 <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 254>>  
  
  # create a random log with ets 

  describe "log mutations" do

    test "create a new empty tree" do

      tree = Bargad.Log.new("FRZ", :sha256, [{"module", "ETSBackend"}])
      
      assert tree.root == @empty
      assert tree.size == 0

    end

    test "build a new tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1"])

      assert tree.root == @h1
      assert tree.size == 1
      
    end

    test "build a new tree with 2 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2"])

      assert tree.root == @h1_2
      assert tree.size == 2

      root = Bargad.Utils.get_node(tree, tree.root)
      assert root.children == [@h1, @h2]
      
    end

    test "build a new tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2", "3"])

      assert tree.root == @h1_2_3
      assert tree.size == 3

      root = Bargad.Utils.get_node(tree, tree.root)
      assert root.children == [@h1_2, @h3]

      left = Bargad.Utils.get_node(tree, List.first(root.children))
      assert left.children == [@h1, @h2]
      
    end

    test "build a new tree with 6 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2", "3","4","5","6"])

      assert tree.root == @h1_2_3_4_5_6
      assert tree.size == 6

      root = Bargad.Utils.get_node(tree, tree.root)
      assert root.children == [@h1_2_3_4, @h5_6]

      left = Bargad.Utils.get_node(tree, List.first(root.children))
      assert left.children == [@h1_2, @h3_4]

      right = Bargad.Utils.get_node(tree, List.last(root.children))
      assert right.children == [@h5, @h6]

      left_left = Bargad.Utils.get_node(tree, List.first(left.children))
      assert left_left.children == [@h1, @h2]
      
      left_right = Bargad.Utils.get_node(tree, List.last(left.children))
      assert left_right.children == [@h3, @h4]

    end

    test "insert a new node in an empty tree" do

      tree = Bargad.Log.new("FRZ", :sha256, [{"module", "ETSBackend"}])

      tree = Bargad.Log.insert(tree, "1")

      assert tree.root == @h1
      assert tree.size == 1
      
    end

    test "insert a node in a tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1"])

      tree = Bargad.Log.insert(tree, "2")

      assert tree.root == @h1_2
      assert tree.size == 2
      
    end

    test "insert a node in a tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1","2","3"])

      tree = Bargad.Log.insert(tree, "4")

      assert tree.root == @h1_2_3_4
      assert tree.size == 4
      
    end

    test "insert a node in a tree with 6 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1","2","3","4","5","6"])

      tree = Bargad.Log.insert(tree, "7")

      assert tree.root == @h1_2_3_4_5_6_7
      assert tree.size == 7
      
    end

  end

  describe "tree get operations" do
    
    test "generate audit proof for a tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1"])

      assert Bargad.Log.audit_proof(tree, 1) == %{proof: [], value: "1", hash: @h1}

    end

    test "generate audit proof for a tree with 2 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2"])

      assert Bargad.Log.audit_proof(tree, 1) == %{proof: [{@h2, "R"}], value: "1", hash: @h1}

      assert Bargad.Log.audit_proof(tree, 2) == %{proof: [{@h1, "L"}], value: "2", hash: @h2}
      
    end

    test "generate audit proof for a tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2", "3"])

      assert Bargad.Log.audit_proof(tree, 1) == %{proof: [{@h2, "R"}, {@h3, "R"}], value: "1", hash: @h1}

      assert Bargad.Log.verify_audit_proof(tree, Bargad.Log.audit_proof(tree, 1))
      
      assert Bargad.Log.audit_proof(tree, 2) == %{proof: [{@h1, "L"}, {@h3, "R"}], value: "2", hash: @h2}

      assert Bargad.Log.audit_proof(tree, 3) == %{proof: [{@h1_2, "L"}], value: "3", hash: @h3}
      
    end

    test "generate audit proof for a tree with 6 nodes" do
      
      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2", "3", "4", "5", "6"])

      assert Bargad.Log.audit_proof(tree, 1) == %{proof: [{@h2, "R"}, {@h3_4, "R"}, {@h5_6, "R"}], value: "1", hash: @h1}

      assert Bargad.Log.audit_proof(tree, 5) == %{proof: [{@h6, "R"},{@h1_2_3_4, "L"}], value: "5", hash: @h5}
      
    end
    
    test "generate consistency proof for a tree with 8 nodes" do
      
      tree = Bargad.Log.build("FRZ", :sha256, [{"module", "ETSBackend"}], ["1", "2", "3", "4", "5", "6", "7", "8"])

      case Bargad.Log.consistency_proof(tree, 3) do
        [@h1_2, @h3] -> assert true
        _ -> assert false
      end

      case Bargad.Log.consistency_proof(tree, 4) do
        [@h1_2_3_4] -> assert true
        _ -> assert false
      end

      case Bargad.Log.consistency_proof(tree, 5) do
        [@h1_2_3_4, @h5] -> assert true
        _ -> assert false
      end

      case Bargad.Log.consistency_proof(tree, 6) do
        [@h1_2_3_4, @h5_6] -> assert true
        _ -> assert false
      end
      
    end

    test "create a new map, insert key value pairs" do
      map = Bargad.Map.new("map", :sha256, [{"module", "ETSBackend"}])
             |> Bargad.Map.set(@k1, "1")
             |> Bargad.Map.set(@k7, "7")
             |> Bargad.Map.set(@k6, "6")
             |> Bargad.Map.set(@k2, "2")

      assert SparseMerkle.audit_tree(map) == [{"L", "L", "1"}, {"L", "R", "2"}, {"R", "L", "6"}, {"R", "R", "7"}]
    end

    test "get with inclusion proof for a map" do


      map = Bargad.Map.new("map", :sha256, [{"module", "ETSBackend"}])
             |> Bargad.Map.set(@k1, "1")
             |> Bargad.Map.set(@k7, "7")
             |> Bargad.Map.set(@k6, "6")
             |> Bargad.Map.set(@k2, "2")

      # IO.inspect SparseMerkle.audit_tree(map)

      IO.inspect Bargad.Map.get(map, @k0)

      assert Bargad.Map.get(map, @k2) == %{key: @k2, proof: [{Bargad.Utils.make_hash(map, Bargad.Utils.salt_node(@k1, "1")), "L"}, { Bargad.Utils.make_hash(map, Bargad.Utils.make_hash(map, Bargad.Utils.salt_node(@k6, "6")) <> Bargad.Utils.make_hash(map, Bargad.Utils.salt_node(@k7, "7"))) , "R"}], value: "2", hash: Bargad.Utils.make_hash(map, Bargad.Utils.salt_node(@k2, "2"))} 
    end


    test "delete values from a map" do
      map = Bargad.Map.new("map", :sha256, [{"module", "ETSBackend"}])
             |> Bargad.Map.set(@k1, "1")
             |> Bargad.Map.set(@k7, "7")
             |> Bargad.Map.set(@k6, "6")
             |> Bargad.Map.set(@k2, "2")

      map = Bargad.Map.delete(map, @k2)

      assert SparseMerkle.audit_tree(map) == [{"L", "1"}, {"R", "L", "6"}, {"R", "R", "7"}] 
    end


  end


end
