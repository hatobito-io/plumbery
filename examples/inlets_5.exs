defmodule Example do
  use Plumbery
  import Plumbery.Request
  defp act(req), do: success(req, req.context.actor)

  pipeline :example_pipeline do
    pipe :act
    unwrap true
    inlet entry(), use_context: true
  end
end

{:ok, :system} = Example.entry(%{actor: :system})
