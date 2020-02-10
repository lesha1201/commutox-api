defmodule CommutoxUtils.MapTest do
  use ExUnit.Case, async: true

  import CommutoxUtils.Map

  describe "to_camel_case/1" do
    test "converts keys in atom-key map to camel case" do
      map = %{
        first_name: "First name",
        last_name: "Last name",
        phone: %{
          cellPhone: "Cell phone",
          work_phone: "Work phone",
          HomePhone: "Home phone"
        }
      }

      expected_result = %{
        "firstName" => "First name",
        "lastName" => "Last name",
        "phone" => %{
          "cellPhone" => "Cell phone",
          "homePhone" => "Home phone",
          "workPhone" => "Work phone"
        }
      }

      assert to_camel_case(map) == expected_result
    end

    test "converts keys in string-key map to camel case" do
      map = %{
        "first_name" => "First name",
        "last_name" => "Last name",
        "phone" => %{
          "cellPhone" => "Cell phone",
          "HomePhone" => "Home phone",
          "work_phone" => "Work phone"
        }
      }

      expected_result = %{
        "firstName" => "First name",
        "lastName" => "Last name",
        "phone" => %{
          "cellPhone" => "Cell phone",
          "homePhone" => "Home phone",
          "workPhone" => "Work phone"
        }
      }

      assert to_camel_case(map) == expected_result
    end

    test "converts keys in map with list of maps to camel case" do
      map = %{
        list_of_maps: [%{first_name: "First name"}, %{last_name: "Last name"}]
      }

      expected_result = %{
        "listOfMaps" => [%{"firstName" => "First name"}, %{"lastName" => "Last name"}]
      }

      assert to_camel_case(map) == expected_result
    end

    test "converts keys in list of maps to camel case" do
      list_of_maps = [%{first_name: "First name"}, %{last_name: "Last name"}]

      expected_result = [%{"firstName" => "First name"}, %{"lastName" => "Last name"}]

      assert to_camel_case(list_of_maps) == expected_result
    end
  end
end
