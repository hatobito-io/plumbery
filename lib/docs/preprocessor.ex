defmodule Plumbery.Docs.Preprocessor do
  @moduledoc false
  @behaviour ExDoc.Markdown

  def available?() do
    ExDoc.Markdown.Earmark.available?()
  end

  def to_ast(text, opts) do
    text
    |> preprocess()
    |> ExDoc.Markdown.Earmark.to_ast(opts)
  end

  defp preprocess(text) do
    text
    |> replace_code()
  end

  defp replace_code(text) do
    Regex.replace(~r"!elixir[ \t]+([^ \t\r\n]+)", text, fn _, filename ->
      content =
        File.read!(filename)

      """
      ```elixir
      #{content}
      ```
      """
    end)
  end
end
