defmodule BargadTest do
  use ExUnit.Case
  doctest Bargad

  @empty <<218, 57, 163, 238, 94, 107, 75, 13, 50, 85, 191, 239, 149, 96, 24, 144, 175, 216, 7, 9>>

  @h1 <<53, 106, 25, 43, 121, 19, 176, 76, 84, 87, 77, 24, 194, 141, 70, 230, 57, 84, 40, 171>>

  @h2 <<218, 75, 146, 55, 186, 204, 205, 241, 156, 7, 96, 202, 183, 174, 196, 168, 53, 144, 16, 176>>
 
  @h3 <<119, 222, 104, 218, 236, 216, 35, 186, 187, 181, 142, 219, 28, 142, 20, 215, 16, 110, 131, 187>>

  @h4 <<27, 100, 83, 137, 36, 115, 164, 103, 208, 115, 114, 212, 94, 176, 90, 188, 32, 49, 100, 122>>

  @h5 <<172, 52, 120, 214, 154, 60, 129, 250, 98, 230, 15, 92, 54, 150, 22, 90, 78, 94, 106, 196>>

  @h6 <<193, 223, 217, 110, 234, 140, 194, 182, 39, 133, 39, 91, 202, 56, 172, 38, 18, 86, 226, 120>>

  @h7 <<172, 52, 120, 214, 154, 60, 129, 250, 98, 230, 15, 92, 54, 150, 22, 90, 78, 94, 106, 196>>

  @h1_2 <<88, 198, 145, 40, 49, 223, 67, 26, 82, 175, 60, 216, 24, 202, 163, 82, 246, 13, 141, 176>>

  @h1_2_3 <<197, 111, 91, 7, 167, 28, 233, 238, 122, 156, 145, 160, 50, 205, 78, 212, 3, 178, 2, 96>>

  @h3_4 <<143, 58, 105, 241, 14, 191, 252, 38, 83, 232, 97, 34, 47, 22, 177, 120, 245, 131, 0, 95>>

  @h5_6 <<210, 133, 109, 55, 194, 244, 115, 80, 41, 24, 63, 141, 231, 115, 160, 250, 233, 79, 160, 3>>

  @h5_6_7 <<143, 182, 119, 179, 164, 93, 79, 79, 188, 43, 205, 155, 198, 177, 123, 125, 27, 138, 240, 28>>

  @h1_2_3_4 <<6, 226, 180, 166, 142, 39, 184, 102, 21, 21, 232, 8, 86, 246, 70, 130, 43, 72, 64, 49>>

  @h1_2_3_4_5_6 <<120, 40, 116, 43, 60, 185, 158, 17, 16, 40, 129, 254, 96, 65, 17, 8, 129, 40, 199, 196>>

  @h1_2_3_4_5_6_7 <<221, 46, 128, 21, 69, 66, 247, 111, 197, 175, 235, 149, 111, 42, 98, 197, 75, 193, 110, 24>>
  
  # create a random log with ets 

  describe "log mutations" do

    test "create a new empty tree" do

      tree = Bargad.Log.new("FRZ", :sha, [{"module", "ETSBackend"}])
      
      assert tree.root == @empty
      assert tree.size == 0

    end

    test "build a new tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1"])

      assert tree.root == @h1
      assert tree.size == 1
      
    end

    test "build a new tree with 2 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2"])

      assert tree.root == @h1_2
      assert tree.size == 2

      root = Bargad.Utils.get_node(tree, tree.root)
      assert root.children == [@h1, @h2]
      
    end

    test "build a new tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2", "3"])

      assert tree.root == @h1_2_3
      assert tree.size == 3

      root = Bargad.Utils.get_node(tree, tree.root)
      assert root.children == [@h1_2, @h3]

      left = Bargad.Utils.get_node(tree, List.first(root.children))
      assert left.children == [@h1, @h2]
      
    end

    test "build a new tree with 6 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2", "3","4","5","6"])

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

      tree = Bargad.Log.new("FRZ", :sha, [{"module", "ETSBackend"}])

      tree = Bargad.Log.insert(tree, "1")

      assert tree.root == @h1
      assert tree.size == 1
      
    end

    test "insert a node in a tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1"])

      tree = Bargad.Log.insert(tree, "2")

      assert tree.root == @h1_2
      assert tree.size == 2
      
    end

    test "insert a node in a tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1","2","3"])

      tree = Bargad.Log.insert(tree, "4")

      assert tree.root == @h1_2_3_4
      assert tree.size == 4
      
    end

    test "insert a node in a tree with 6 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1","2","3","4","5","6"])

      tree = Bargad.Log.insert(tree, "7")

      assert tree.root == @h1_2_3_4_5_6_7
      assert tree.size == 7
      
    end

  end

  describe "tree get operations" do
    
    test "generate audit proof for an empty tree" do

      tree = Bargad.Log.new("FRZ", :sha, [{"module", "ETSBackend"}])

      case Bargad.Log.audit_proof(tree, @h1) do
        [:not_found] -> assert true
        _ -> assert false
      end
      
    end

    test "generate audit proof for a tree with 1 node" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1"])

      case Bargad.Log.audit_proof(tree, @empty) do
        [:not_found] -> assert true
        _ -> assert false
      end

      case Bargad.Log.audit_proof(tree, @h1) do
        [:found, {@h1, "L"}] -> assert true
        _ -> assert false
      end

    end

    test "generate audit proof for a tree with 2 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2"])

      case Bargad.Log.audit_proof(tree, @h1) do
        [:found, {@h2, "R"}] -> assert true
        _ -> assert false
      end

      case Bargad.Log.audit_proof(tree, @h2) do
        [:found, {@h1, "L"}] -> assert true
        _ -> assert false
      end
      
    end

    test "generate audit proof for a tree with 3 nodes" do

      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2", "3"])

      case Bargad.Log.audit_proof(tree, @h1) do
        [:found, {@h2, "R"}, {@h3, "R"}] -> assert true
        _ -> assert false
      end

      case Bargad.Log.audit_proof(tree, @h2) do
        [:found, {@h1, "L"}, {@h3, "R"}] -> assert true
        _ -> assert false
      end

      case Bargad.Log.audit_proof(tree, @h3) do
        [:found, {@h1_2, "L"}] -> assert true
        _ -> assert false
      end
      
    end

    test "generate audit proof for a tree with 6 nodes" do
      
      tree = Bargad.Log.build("FRZ", :sha, [{"module", "ETSBackend"}], ["1", "2", "3", "4", "5", "6"])

      case Bargad.Log.audit_proof(tree, @h1) do
        [:found, {@h2, "R"}, {@h3_4, "R"}, {@h5_6, "R"}] -> assert true  
        _ -> assert false
      end

      case Bargad.Log.audit_proof(tree, @h5) do
        [:found, {@h6, "R"},{@h1_2_3_4, "L"}] -> assert true
        _ -> assert false
      end
      
    end

  end


end
