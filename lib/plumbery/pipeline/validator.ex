defmodule Plumbery.Pipeline.Validator do
  @moduledoc false
  alias Plumbery.Pipeline

  def validate(pipeline = %Pipeline{}) do
    file_line = extract_location()
    {:ok, %{pipeline | file_line: file_line}}
  end

  defp extract_location() do
    {_, stack} = Process.info(self(), :current_stacktrace)

    case Enum.find(stack, &match?({_, :__MODULE__, _, [file: _, line: _8]}, &1)) do
      nil -> []
      {_, _, _, file_line} -> file_line
    end
  end
end
