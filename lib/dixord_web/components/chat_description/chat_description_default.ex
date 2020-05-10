defmodule DixordWeb.Components.ChatDescription.Default do
  @moduledoc """
  """
  use Surface.Component
  alias DixordWeb.Components.ChatDescription.Row

  property(dixord_info, :string,
    default:
      raw(
        "<b>Dixord is a clone of Discord</b>, a free messaging app with communities (<i>servers</i>) and chats (<i>channels</i>).</p>"
      )
  )

  property(is_open_source, :string,
    default:
      raw(
        "<p><b>Dixord is <a href='https://github.com/SolbiatiAlessandro/dixord'>open source</a></b>, everyone can contribute in fixing bug and building new features.</p>"
      )
  )

  property(contribute, :string,
    default:
      raw(
        "<p><b>Dixord is entirely written in <a href='https://elixir-lang.org/'>Elixir</a></b>, you can take a look at our <a href='https://github.com/SolbiatiAlessandro/dixord/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22'>good first issues</a> to start your Elixir journey.</p>"
      )
  )

  def render(assigns) do
    ~H"""
    <Row icon="bang" description={{ @dixord_info }} />
    <Row icon="computer" description={{ @is_open_source }} />
    <Row icon="pen" description={{ @contribute }} />
    """
  end
end
