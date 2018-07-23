defmodule ETSBackend do
    @behaviour 

    def get_node(store, key) do
        #:ets.lookup(store.table, key)
    end

    def set_node(store, key, value) do
        #:ets.insert_new(store.table, value)
    end

end