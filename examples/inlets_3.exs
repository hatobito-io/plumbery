defmodule Example do
  use Plumbery
  import Plumbery.Request
  defp mul_xy(%{command: %{x: x, y: y}} = req), do: success(req, x * y)

  pipeline :multiply_pipeline do
    private true
    unwrap true
    pipe :mul_xy
    inlet multiply(x, y \\ 2) when is_number(x) and is_number(y)
    # This requires x and y to be the same
    inlet multiply_x_x(x, y = x) when is_number(x)
  end
end

{:ok, 999} = Example.multiply(9, 111)
{:ok, 18} = Example.multiply(9)
{:ok, 81} = Example.multiply_x_x(9, 9)
# raises FunctionClauseError
{:ok, 90} = Example.multiply_x_x(9, 10)
