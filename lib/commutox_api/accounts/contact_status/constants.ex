defmodule CommutoxApi.Accounts.ContactStatus.Constants do
  def pending do
    %{name: "Pending", code: "PND"}
  end

  def accepted do
    %{name: "Accepted", code: "ACC"}
  end

  def rejected do
    %{name: "Rejected", code: "REJ"}
  end
end
