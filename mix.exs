defmodule Bargad.MixProject do
  use Mix.Project

  def project do
    [
      app: :bargad,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Bargad",
      source_url: "https://github.com/farazhaider/bargad",
      docs: docs()
    ]
  end

  defp description do
    "A Data Integrity framework for building efficient blockchains, transparency logs and secure file systems among others."
  end

  defp package do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "bargad",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README.md license.md),
      maintainers: ["Faraz Haider"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/ZanjeerPlatform/bargad"
      }
    ]
  end

  def docs do
    [
      main: "Bargad",
      extra_section: "guides",
      extras: extras(),
      groups_for_modules: groups_for_modules()
    ]
  end

  def extras do
    ["README.md"]
  end

  def groups_for_modules do
    [
      Service: [
        Bargad
      ],
      Modes: [
        Bargad.Log,
        Bargad.Map
      ],
      Clients: [
        Bargad.LogClient,
        Bargad.MapClient
      ],
      Backends: [
        ETSBackend,
        Storage,
        Bargad.TreeStorage
      ],
      Merkle: [
        Bargad.Merkle,
        Bargad.SparseMerkle
      ],
      Utils: [
        Bargad.Utils
      ],
      Types: [
        Bargad.Types
      ],
      Protobuf: [
        Bargad.Trees,
        Bargad.Nodes
      ],
      Supervisor: [
        Bargad.Supervisor
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:exprotobuf, :logger],
      mod: {Bargad, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exprotobuf, "~> 1.2"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
