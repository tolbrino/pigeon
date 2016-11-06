defmodule Pigeon.Mixfile do
  use Mix.Project

  def project do
    [app: :pigeon,
     name: "Pigeon",
     version: "0.9.2",
     elixir: "~> 1.2",
     source_url: "https://github.com/codedge-llc/pigeon",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
    mod: {Pigeon, []}]
  end

  defp deps do
    [
      {:poison, "~> 3.0"},
      {:httpoison, "~> 0.7"},
      {:chatterbox, github: "joedevivo/chatterbox"},
      {:dogma, "~> 0.1", only: :dev},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.2", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
    ]
  end

  defp description do
    """
    HTTP2-compliant wrapper for sending iOS (APNS) and Android (GCM) push notifications.
    """
  end

  defp package do
    [
       files: ["lib", "mix.exs", "README*", "LICENSE*"],
       maintainers: ["Henry Popp", "Tyler Hurst"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/codedge-llc/pigeon"}
    ]
  end
end
