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

defmodule Bargad do
  @moduledoc """

  Bargad is a service which implements a Merkle tree whose contents are served from a data storage layer
  which allows to be extremely scalable.

  Make the readme and this module doc same.

  """
  use Application

  def start(_type, _args) do
    Bargad.Supervisor.start_link
  end

end
