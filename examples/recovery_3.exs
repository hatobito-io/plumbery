defmodule Example do
  use Plumbery
  import Plumbery.Request

  def halter(req) do
    req
    |> success(:halted)
    |> halt()
  end

  def skipper(req) do
    req
    |> success(:skipped)
  end

  pipeline :haltable do
    pipe :halter
    pipe :skipper
  end
end

# skipper will not have a chance to be called because halter halts the pipeline
%{result: {:ok, :halted}, halted?: true} =
  Example.haltable(%Plumbery.Request{})
