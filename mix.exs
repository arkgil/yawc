defmodule YAWC.MixProject do
  use Mix.Project

  def project do
    [
      app: :yawc,
      version: "0.1.0",
      name: "YAWC",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :docs, runtime: false}
    ]
  end

  defp docs do
    [
      main: "README",
      extras: ["README.md"]
    ]
  end

  defp preferred_cli_env() do
    [
      docs: :docs
    ]
  end
end
