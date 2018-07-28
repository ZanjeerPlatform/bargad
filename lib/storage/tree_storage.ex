defmodule Bargad.TreeStorage do
    @moduledoc """
    Implements a `:dets` key value storage for persisting tree heads.
    This enables `Bargad` to support multiple trees.
    """

    @doc """

    Initializes `:dets` with a table `:tree_table`.
    
    The table is created if it does not exist.
    """
    def initialize() do
        :dets.open_file(:tree_table, [type: :set])
    end

    @doc """
    Saves a tree with the specified key in `:dets`.
    """
    def save_tree(key, value) do
        :dets.insert(:tree_table, {key, value})
    end

    @doc """
    Retrives a tree with the specified key from `:dets`.
    """
    def load_tree(key) do
        :dets.lookup(:tree_table, key)
    end

    @doc """
    Deletes a tree with the specified key from `:dets`.
    """
    def delete_tree(key) do
        :dets.delete(:tree_table, key)
    end

end