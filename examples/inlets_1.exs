defmodule Example do
  use Plumbery
  import Plumbery.Request
  defp mul_xy(%{command: %{x: x, y: y}} = req), do: success(req, x * y)

  pipeline :multiply do
    pipe :mul_xy
  end
end

%{result: {:ok, 999}} =
  %Plumbery.Request{command: %{x: 9, y: 111}}
  |> Example.multiply()
