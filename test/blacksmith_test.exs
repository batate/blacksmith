defmodule BlacksmithTest do
  use ExUnit.Case
  use ShouldI, async: true
  import ShouldI.Matchers.Context

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
  end
  
  with "a persistent user and a persistent user list" do
    setup context do
      repo = [:existing]
      assign context, 
        saved_user: Forge.saved_user( repo ), 
        saved_user_list: Forge.saved_user_list(repo, 2)
    end
    
    should_have_key :saved_user
    should_have_key :saved_user_list
  end
  
end
