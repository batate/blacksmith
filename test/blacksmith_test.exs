defmodule BlacksmithTest do
  use ExUnit.Case
  use ShouldI
  import ShouldI.Matchers.Context
  require Forge

  with "a direct map and a prototype" do
    setup context do
      assign context,
        user: Forge.user,
        user_list: Forge.user_list(2)
    end

    should_have_key :user
    should_have_key :user_list
    should_match_key user: %{name: _}
    should_match_key user_list: [%{name: _}|_]

    should "create different users", context do
      [user1, user2] = context.user_list
      assert user1.email != user2.email
    end
  end

  with "optional args" do
    setup context do
      assign context,
        user: Forge.user( job: "Iron worker" ),
        extra_arg_user: Forge.user( job: "Iron worker", job: "Steel driver" )
    end

    should_match_key user: %{job: "Iron worker"}
    should_match_key extra_arg_user: %{job: "Steel driver"}
  end

  with "having args" do
    setup context do
      Forge.having job: "Steel driver" do
        context = assign context, user1: Forge.user
      end

      Forge.having city: "Austin" do
        assign context, user2: Forge.user
      end
    end

    should_match_key user1: %{job: "Steel driver"}
    should_match_key user2: %{city: "Austin"}
  end

  # with "nested having args" do
  #   setup context do
  #     Forge.having( tool: "hammer" ) do
  #       Forge.having( job: "Steel driver" ) do
  #         assign context,
  #           user: Forge.user
  #       end
  #     end
  #   end
  #
  #   should_match_key user: %{job: "Steel driver"}
  #   should_match_key user: %{tool: "hammer"}
  # end

  with "a persistent user and a persistent user list" do
    setup context do
      assign context,
        saved_user: Forge.saved_user,
        saved_user_list: Forge.saved_user_list(2)
    end

    should_have_key :saved_user
    should_have_key :saved_user_list
  end

end
