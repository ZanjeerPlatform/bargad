defmodule Storage do
    @callback init_backend(term) :: term
    @callback set_node(term,term,term) :: term
    @callback get_node(term,term) :: term


    def set_node(backend,key,value) do
        backend["module"].set_node(backend,key,value)
    end

    def get_node(backend,key) do
        backend["module"].get_node(backend,key)
    end

end