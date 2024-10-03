defmodule Plumbery.Pipe.Validator do
  @moduledoc false
  alias Plumbery.Pipe

  def validate(pipe = %Pipe{}) do
    file_line = extract_location()
    {:ok, %{pipe | file_line: file_line}}
  end

  defp extract_location() do
    {:current_stacktrace, stack} = Process.info(self(), :current_stacktrace)

    case Enum.find(stack, &match?({_, :__MODULE__, _, [file: _, line: _8]}, &1)) do
      nil -> []
      {_, _, _, file_line} -> file_line
    end
  end
end
