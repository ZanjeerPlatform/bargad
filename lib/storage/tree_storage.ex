defmodule Bargad.TreeStorage do

    def initialize() do
        :dets.open_file(:tree_table, [type: :set])
    end

    def save_tree(key, value) do
        :dets.insert(:tree_table, {key, value})
    end

    def delete_tree(key) do
        :dets.delete(:tree_table, key)
    end

end