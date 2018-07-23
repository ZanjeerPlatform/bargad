defmodule Storage do
    @callback set_node(term,term) :: term
    @callback get_node(term,term) :: term
end