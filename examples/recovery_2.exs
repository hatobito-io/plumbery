defmodule Example do
  use Plumbery
  import Plumbery.Request

  defp validate_x(req = %{command: %{x: x}}) when is_number(x) and x > 0, do: req
  defp validate_x(req), do: add_error(req, :x, "is invalid")

  defp validate_y(req = %{command: %{y: y}}) when is_number(y) and y > 0, do: req
  defp validate_y(req), do: add_error(req, :y, "is invalid")

  defp validate_name(req = %{command: %{name: "John"}}), do: req
  defp validate_name(req), do: add_error(req, :name, "not John")

  pipeline :validate_number_y do
    escape_on_error false
    pipe :validate_y
  end

  defp calculate(req = %{command: command}) do
    success(req, "Hello #{command.name}! x+y = #{command.x + command.y}")
  end

  pipeline :run do
    escape_on_error false
    pipe :validate_x
    pipe :validate_number_y
    pipe :validate_name

    escape_on_error true
    pipe :calculate
  end
end

# Now all expected errors are reported
%{result: {:error, [x: "is invalid", y: "is invalid", name: "not John"]}} =
  Example.run(%Plumbery.Request{command: %{name: "Jim", x: -20, y: 0}})

%{result: {:error, [x: "is invalid", y: "is invalid"]}} =
  Example.run(%Plumbery.Request{command: %{name: "John", x: -20, y: 0}})

# And the `:calculate' pipe is called only if there were no errors
%{result: {:ok, "Hello John! x+y = 99"}} =
  Example.run(%Plumbery.Request{command: %{name: "John", x: 90, y: 9}})
