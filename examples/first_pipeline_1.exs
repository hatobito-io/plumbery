defmodule Example do
  use Plumbery
  import Plumbery.Request

  defp validate(req = %Plumbery.Request{command: 42}), do: assign(req, :validated, true)
  defp validate(req), do: error(req, :no_luck)

  defp act(req), do: success(req, "You are lucky")

  pipeline :lucky_number do
    pipe :validate
    pipe :act
  end
end

%{result: {:ok, "You are lucky"}, assigns: %{validated: true}} =
  Example.lucky_number(%Plumbery.Request{command: 42})

%{result: {:error, :no_luck}} = Example.lucky_number(%Plumbery.Request{command: 41})
