# Copyright 2018 OmiseGO Pte Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule AdminAPI.V1.AccountScopePlugTest do
  use AdminAPI.ConnCase, async: true
  alias AdminAPI.V1.AccountScopePlug
  alias Ecto.UUID

  # Lower-case header keys is enforced by `Plug.Conn` and only in test environments,
  # otherwise it will raise an `InvalidHeaderError`.
  # See https://github.com/elixir-plug/plug/blob/master/lib/plug/conn.ex
  @header_name "omgadmin-account-id"

  describe "AccountScopePlug.call/2" do
    test "assigns scoped_account_id to the connection if the header value is a UUID" do
      account_id = UUID.generate()
      conn = test_with(account_id)

      refute conn.halted
      assert conn.assigns.scoped_account_id == account_id
    end

    test "halts with error if the header is provided but not a UUID" do
      conn = test_with("not-a-uuid")

      assert conn.halted
      refute Map.has_key?(conn.assigns, :scoped_account_id)
    end

    test "skips and does not assign scoped_account_id if the header is not provided" do
      conn = AccountScopePlug.call(build_conn(), [])

      refute conn.halted
      refute Map.has_key?(conn.assigns, :scoped_account_id)
    end
  end

  defp test_with(account_id) do
    build_conn()
    |> put_req_header(@header_name, account_id)
    |> AccountScopePlug.call([])
  end
end
