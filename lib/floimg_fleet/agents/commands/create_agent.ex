defmodule FloimgFleet.Agents.Commands.CreateAgent do
  @moduledoc """
  Command to create a new bot.

  ## Examples

      iex> execute(%CreateBot{name: "PhotoBot", username: "photobot"})
      {:ok, %Agent{}}

      iex> execute(%CreateBot{name: "", username: "photobot"})
      {:error, %Ecto.Changeset{}}

  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.Agent

  @enforce_keys [:name, :username]
  defstruct [
    :name,
    :username,
    :persona_id,
    :personality,
    :vibe,
    interests: [],
    post_probability: 0.3,
    comment_probability: 0.4,
    like_probability: 0.5,
    min_action_interval_seconds: 60,
    max_action_interval_seconds: 300
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          username: String.t(),
          persona_id: String.t() | nil,
          personality: String.t() | nil,
          vibe: String.t() | nil,
          interests: [String.t()],
          post_probability: float(),
          comment_probability: float(),
          like_probability: float(),
          min_action_interval_seconds: pos_integer(),
          max_action_interval_seconds: pos_integer()
        }

  @spec execute(t()) :: {:ok, Agent.t()} | {:error, Ecto.Changeset.t()}
  def execute(%__MODULE__{} = command) do
    attrs = Map.from_struct(command)

    %Agent{}
    |> Agent.changeset(attrs)
    |> Repo.insert()
  end
end
