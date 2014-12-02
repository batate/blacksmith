defmodule Blacksmith.SequenceTest do
  use ExUnit.Case
  use ShouldI, async: false
  require Forge

  alias Blacksmith.Sequence

  should "return the default sequence" do
    start = Sequence.next
    assert start + 1 == Sequence.next
    assert start + 2 == Sequence.next(:default)
  end

  should "have many sequence names" do
    start = Sequence.next
    other = Sequence.next(:other)
    assert start + 1 == Sequence.next
    assert other + 1 == Sequence.next(:other)
  end

  should "format sequences for us" do
    start = Sequence.next(:email)
    assert "email#{start+1}@example.com" == Sequence.next(:email, &"email#{&1}@example.com")
    assert "email#{start+2}@example.com" == Sequence.next(:email, &"email#{&1}@example.com")
  end

  should "allow default sequence formatters" do
    start = Sequence.next
    assert "foo #{start+1}" == Sequence.next(&"foo #{&1}")
  end

  with "a forge" do
    setup context do
      assign context,
        start: Sequence.next(:email),
        user1: Forge.user,
        user2: Forge.user
    end

    should "have incremented the emails appropriately", context do
      assert "jh#{context.start+1}@example.com" == context.user1.email
      assert "jh#{context.start+2}@example.com" == context.user2.email
    end
  end
end
