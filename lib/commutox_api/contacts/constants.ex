defmodule CommutoxApi.Contacts.Constants do
  @type contact_status_code :: String.t()
  @type contact_status_name :: String.t()
  @type contact_status :: %{name: contact_status_name(), code: contact_status_code()}

  @spec pending() :: contact_status()
  def pending do
    %{name: "Pending", code: "PND"}
  end

  @spec accepted() :: contact_status()
  def accepted do
    %{name: "Accepted", code: "ACC"}
  end

  @spec rejected() :: contact_status()
  def rejected do
    %{name: "Rejected", code: "REJ"}
  end
end
