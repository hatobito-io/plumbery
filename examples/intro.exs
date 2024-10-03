defmodule Example do
  use Plumbery
  import Plumbery.Request

  defp validate(req = %Plumbery.Request{}) do
    case req.command do
      %{number: n, mul: m} when is_integer(n) and n > 0 and is_integer(m) -> req
      _ -> error(req, :invalid_number)
    end
  end

  defp calculate(req = %Plumbery.Request{command: %{number: n, mul: m}}) do
    success(req, n * m)
  end

  pipeline :mult do
    private true
    unwrap true

    pipe :validate
    pipe :calculate

    inlet multiply(number, mul \\ 42) when is_integer(number), use_context: false
  end
end

{:error, :invalid_number} = Example.multiply(0)
{:ok, 126} = Example.multiply(3)
{:ok, 56} = Example.multiply(7, 8)
