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
    pipe :validate_y
  end

  defp calculate(req = %{command: command}) do
    success(req, "Hello #{command.name}! x+y = #{command.x + command.y}")
  end

  pipeline :run do
    pipe :validate_x
    pipe :validate_number_y
    pipe :validate_name
    pipe :calculate
  end
end

# We expect to see 3 errors, but this fails
%{result: {:error, [x: "is invalid", y: "is invalid", name: "not John"]}} =
  Example.run(%Plumbery.Request{command: %{name: "Jim", x: -20, y: 0}})

# This is what we actually get
%{result: {:error, [x: "is invalid"]}} =
  Example.run(%Plumbery.Request{command: %{name: "Jim", x: -20, y: 0}})
