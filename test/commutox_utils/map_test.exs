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

  describe "get_one_of/2" do
    test "it should return {key, value} tuple for the first available key" do
      assert get_one_of(%{b: 2}, [:a, :b]) == {:b, 2}
      assert get_one_of(%{a: 1, b: 2}, [:a, :b]) == {:a, 1}
      assert get_one_of(%{b: 2, a: 1}, [:a, :b]) == {:a, 1}
    end

    test "it should return result only for non-nil values" do
      map = %{a: nil, b: 2}

      assert get_one_of(map, [:a, :b]) == {:b, 2}
    end

    test "it should return `nil` when no result" do
      assert get_one_of(%{}, []) == nil
      assert get_one_of(%{}, [:a]) == nil
      assert get_one_of(%{a: nil}, [:a]) == nil
    end
  end
end
