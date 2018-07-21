defmodule Bargad.Node do

    defstruct hash: nil, children: nil, metadata: nil, size: nil

    @type t :: %__MODULE__{
        hash: binary(),
        children: [Bargad.Node.t],
        metadata: any(),
        size: integer()
    }

end