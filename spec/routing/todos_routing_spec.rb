require "spec_helper"

describe TodosController do
  describe "routing" do

    it "routes to #index" do
      get("/todos").should route_to("todos#index")
    end

    it "routes to #new" do
      get("/todos/new").should route_to("todos#new")
    end

    it "routes to #show" do
      get("/todos/1").should route_to("todos#show", :id => "1")
    end

    it "routes to #edit" do
      get("/todos/1/edit").should route_to("todos#edit", :id => "1")
    end

    it "routes to #create" do
      post("/todos").should route_to("todos#create")
    end

    it "routes to #update" do
      put("/todos/1").should route_to("todos#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/todos/1").should route_to("todos#destroy", :id => "1")
    end

  end
end
