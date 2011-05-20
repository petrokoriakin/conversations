class DemoController < ApplicationController
  def backbone
  end

  def chat
     if rand(7) == 1
      render :nothing => true, :status => 404
    else
      #sleep(rand(10));
      render :text => "Hi! Have a random number:  . #{rand 10}"
    end
  end

  def polling
  end

end
