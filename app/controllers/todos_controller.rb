class TodosController < ApplicationController

  def chatroom
     if rand(7) == 1
      render :nothing => true, :status => 404
    else
      #sleep(rand(10));
      render :json =>{ :utterance => "Hi! Have a random number:  . #{rand 10}"}
    end
  end

  def index
     render :json => Todo.all
   end

   def show
     render :json => Todo.find(params[:id])
   end

   def create
     todo = Todo.create! params
     render :json => todo
   end

   def update
     todo = Todo.find(params[:id])
     todo.update_attributes! params
     render :json => todo
   end

   def destroy
    todo = Todo.find(params[:id])
    todo.destroy
    render :json => todo
  end

end