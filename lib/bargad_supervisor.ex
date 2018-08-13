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

defmodule Bargad.Supervisor do

  @moduledoc """

  Supervisor for the `Bargad.LogClient` and  `Bargad.MapClient`.

  Started by `Bargad` on application start.
  
  """

  use Supervisor

  @doc """
    Initializes the `:dets` storage `Bargad.TreeStorage` which stores multiple tree heads. 
    Starts the supervision tree.
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link do
    # Initialize DETS for tree storage
    Bargad.TreeStorage.initialize()
    # Start Supervision Tree
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Bargad.LogClient, name: Bargad.LogClient},
      {Bargad.MapClient, name: Bargad.MapClient}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
