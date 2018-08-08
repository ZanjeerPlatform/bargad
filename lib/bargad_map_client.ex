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

defmodule Bargad.MapClient do

    @moduledoc """
    Client APIs for `Bargad.Map`. This module is automatically started on application start.

    The request in each API has to be of the form `t:request/0`.
    Look into the corresponding handler of each request for the exact arguments to be supplied.
    """

    use GenServer
  
    ## Client API

    @type response :: Bargad.Types.tree | Bargad.Types.audit_proof | boolean 
  
    @type request :: tuple

    @doc """
    Starts the `Bargad.MapClient`.
    
    Provides an API layer for operations on `Bargad.Map`.
    """
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    @spec new(request) :: Bargad.Types.tree
    def new(args) do
        GenServer.call(Bargad.MapClient, {:new, args})
    end

    def set(args) do
        GenServer.call(Bargad.MapClient, {:set, args})
    end

    def get(args) do
        GenServer.call(Bargad.MapClient, {:get, args})
    end
  
    ## Server Callbacks
  
    @doc false
    def init(:ok) do
      {:ok, %{}}
    end
  
    @doc false
    def handle_call({operation, args}, _from, state) do
        args = Tuple.to_list(args)
        result = apply(Bargad.Map, operation, args)
        {:reply, result, state}
    end
    
end