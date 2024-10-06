defmodule Plumbery.Inlet.Validator do
  @moduledoc false
  alias Plumbery.Dsl.Plumbery.Inlet
  alias Plumbery.Inlet

  def validate(inlet = %Plumbery.Inlet{}) do
    inlet
    |> extract_arguments()
    |> validate_request()
  end

  defp extract_arguments(inlet = %Plumbery.Inlet{}) do
    expr = inlet.signature

    {expr, inlet} =
      case expr do
        {:when, _, [expr, whn]} ->
          case whn do
            {_, _, _} ->
              inlet = %Plumbery.Inlet{inlet | when: [whn]}
              {expr, inlet}

            [_ | _] ->
              inlet = %Plumbery.Inlet{inlet | when: whn}
              {expr, inlet}
          end

        _ ->
          {expr, inlet}
      end

    case expr do
      {name, _, args} when is_atom(name) and is_list(args) ->
        if is_var_name(name) do
          %{inlet | name: name, args: args}
          |> extract_arguments(args)
        else
          {:error, "Invalid signature for inlet function"}
        end

      _ ->
        {:error, "Invalid signature for inlet function"}
    end
  end

  defp extract_arguments(inlet = %Plumbery.Inlet{}, []) do
    {:ok, %{inlet | arg_names: Enum.reverse(inlet.arg_names)}}
  end

  defp extract_arguments(inlet = %Plumbery.Inlet{}, [arg | rest]) do
    arg =
      case arg do
        {:\\, _, [arg, _]} -> arg
        arg -> arg
      end

    case is_valid_arg(arg) do
      {name, _pattern} ->
        if is_var_name(name) do
          %{inlet | arg_names: [name | inlet.arg_names]}
          |> extract_arguments(rest)
        else
          {:error, "Invalid signature for inlet function"}
        end

      _ ->
        inlet |> extract_arguments(rest)
    end
  end

  defp validate_request({:error, _} = e), do: e

  defp validate_request({:ok, inlet = %Inlet{}}) do
    req = inlet.request

    case req do
      nil ->
        {:ok, %{inlet | request: Plumbery.Request}}

      module ->
        case Plumbery.Request.conforms(module) do
          :ok -> {:ok, %{inlet | request: module}}
          {:error, err} -> {:error, err}
        end
    end
  end

  defp is_valid_arg({:=, _, [{name, _, nil}, pattern]}), do: {name, pattern}
  defp is_valid_arg({:=, pattern, [_, {name, _, nil}]}), do: {name, pattern}
  defp is_valid_arg({name, _, _}), do: {name, nil}
  defp is_valid_arg(_), do: nil

  defp is_var_name(name) do
    name_str = Atom.to_string(name)
    Regex.match?(~r/^[a-z_]+[a-zA-Z0-9_]*$/, name_str)
  end
end
