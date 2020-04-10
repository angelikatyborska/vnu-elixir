defmodule Vnu.FormatterTest do
  use ExUnit.Case
  alias Vnu.{Formatter, Message}
  import IO.ANSI, only: [red: 0, yellow: 0, blue: 0, cyan: 0, reset: 0, reverse: 0]

  describe "format_messages" do
    test "doesn't fail when no messages" do
      assert Formatter.format_messages([]) == []
    end

    test "uses red for errors, yellow for warnings, and blue for other info" do
      result =
        Formatter.format_messages([
          %Message{
            type: :error,
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
          },
          %Message{
            type: :info,
            sub_type: :warning,
            message: "Ut venenatis imperdiet magna in dignissim."
          },
          %Message{
            type: :info,
            message: "Proin ultrices orci vel lectus blandit, ac vulputate lorem placerat."
          }
        ])

      assert Enum.count(result) == 3

      assert Enum.at(result, 0) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum dolor sit amet, consectetur adipiscing elit."

      assert Enum.at(result, 1) ==
               "#{yellow()}#{reverse()} Warning #{reset()} Ut venenatis imperdiet magna in dignissim."

      assert Enum.at(result, 2) ==
               "#{blue()}#{reverse()} Info #{reset()} Proin ultrices orci vel lectus blandit, ac vulputate lorem placerat."
    end

    test "sorts by first line, formats location" do
      messages = [
        %Message{
          type: :error,
          message: "Lorem ipsum 6.",
          first_line: 6,
          last_line: 7,
          extract: "..."
        },
        %Message{
          type: :error,
          message: "Lorem ipsum 3.",
          first_line: 1,
          last_line: 1,
          extract: "..."
        },
        %Message{
          type: :error,
          message: "Lorem ipsum 1.",
          first_line: nil,
          extract: "..."
        },
        %Message{
          type: :error,
          message: "Lorem ipsum 2.",
          first_line: nil,
          extract: "..."
        },
        %Message{
          type: :error,
          message: "Lorem ipsum 5.",
          first_line: 2,
          last_line: 4,
          first_column: 1,
          last_column: 10,
          extract: "..."
        },
        %Message{
          type: :error,
          message: "Lorem ipsum 4.",
          first_line: 1,
          last_line: 1,
          first_column: 3,
          last_column: 6,
          extract: "..."
        }
      ]

      result = Formatter.format_messages(messages)

      assert Enum.count(result) == 6

      assert Enum.at(result, 0) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 1.\n" <>
                 "..."

      assert Enum.at(result, 1) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 2.\n" <>
                 "..."

      assert Enum.at(result, 2) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 3.\n" <>
                 "#{cyan()}[L1] #{reset()}..."

      assert Enum.at(result, 3) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 4.\n" <>
                 "#{cyan()}[L1:3-6] #{reset()}..."

      assert Enum.at(result, 4) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 5.\n" <>
                 "#{cyan()}[L2:1-L4:10] #{reset()}..."

      assert Enum.at(result, 5) ==
               "#{red()}#{reverse()} Error #{reset()} Lorem ipsum 6.\n" <>
                 "#{cyan()}[L6-7] #{reset()}..."
    end

    test "hilights the extract" do
      result =
        Formatter.format_messages([
          %Message{
            type: :info,
            sub_type: :warning,
            message: "Lorem ipsum.",
            extract: "Ut venenatis imperdiet magna in dignissim.",
            hilite_start: 0,
            hilite_length: 2
          },
          %Message{
            type: :info,
            sub_type: :warning,
            message: "Lorem ipsum.",
            extract: "Ut venenatis imperdiet magna in dignissim.",
            hilite_start: 13,
            hilite_length: 9
          },
          %Message{
            type: :info,
            sub_type: :warning,
            message: "Lorem ipsum.",
            extract: "Ut venenatis imperdiet magna in dignissim.",
            hilite_start: 13,
            hilite_length: 9,
            first_line: 3,
            last_line: 4,
            first_column: 34,
            last_column: 10
          }
        ])

      assert Enum.at(result, 0) ==
               "#{yellow()}#{reverse()} Warning #{reset()} Lorem ipsum.\n" <>
                 "Ut venenatis imperdiet magna in dignissim.\n" <>
                 "#{cyan()}^^#{reset()}"

      assert Enum.at(result, 1) ==
               "#{yellow()}#{reverse()} Warning #{reset()} Lorem ipsum.\n" <>
                 "Ut venenatis imperdiet magna in dignissim.\n" <>
                 "             #{cyan()}^^^^^^^^^#{reset()}"

      assert Enum.at(result, 2) ==
               "#{yellow()}#{reverse()} Warning #{reset()} Lorem ipsum.\n" <>
                 "#{cyan()}[L3:34-L4:10] #{reset()}Ut venenatis imperdiet magna in dignissim.\n" <>
                 "                           #{cyan()}^^^^^^^^^#{reset()}"
    end

    test "replaces newlines in extract with a fancy symbol" do
      result =
        Formatter.format_messages([
          %Message{
            type: :info,
            sub_type: :warning,
            message: "Lorem ipsum.",
            extract: "Ut\nvenenatis\nimperdiet magna in dignissim.",
            hilite_start: 13,
            hilite_length: 9
          }
        ])

      assert Enum.at(result, 0) ==
               "#{yellow()}#{reverse()} Warning #{reset()} Lorem ipsum.\n" <>
                 "Ut↩venenatis↩imperdiet magna in dignissim.\n" <>
                 "             #{cyan()}^^^^^^^^^#{reset()}"
    end
  end
end
