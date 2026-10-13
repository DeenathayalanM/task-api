require 'rails_helper'

RSpec.describe "Tasks", type: :request do

  let(:user) { User.create!(name: 'Deena', email: 'deena@gmail.com' , password: '123456', role: 'user')} 
  let(:admin_user) { User.create!(name: 'Praba', email: 'praba@gmail.com', password: '123456', role: 'admin')} 

   before do
    Task.create!(title: 'test', completed: false, user: user)
    Task.create!(title: 'test1', completed: false, user: user)
    Task.create!(title: 'test1', completed: false, user: admin_user)

   end

  describe "GET /tasks" do

     let(:token) do
       JsonWebToken.encode(user_id: user.id)
      end

      let(:admin_token) do
       JsonWebToken.encode(user_id: admin_user.id)
      end

    it "return user specific record" do    
       get '/tasks' , headers: { 'Authorization' => "Bearer #{token}"}
    
       expect(response).to have_http_status(:ok)
       
       result = JSON.parse(response.body)
       expect(result.size).to eql(2)
    end

     it "return all user record for admin" do    
       get '/tasks' , headers: { 'Authorization' => "Bearer #{admin_token}"}
    
       expect(response).to have_http_status(:ok)
       
       result = JSON.parse(response.body)
       expect(result.size).to eql(3)
    end

       it "fail if token is missing" do    
       get '/tasks' , headers: { 'Authorization' => "Bearer #{}"}
    
       expect(response).to have_http_status(:unauthorized)
       
    end

      it "fail if token invalid" do    
       get '/tasks' , headers: { 'Authorization' => "Bearer #{'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo4fQ.RSOYH5wOHcMpU0JmNalTbSILaQbfwf7OkRVocJvB2m'  }"}
       

       expect(response).to have_http_status(:unauthorized)
       
    end

      it "fail if user access admin record" do    
       get "/tasks/#{Task.all.last.id}" , headers: { 'Authorization' => "Bearer #{token}"}
       expect(response).to have_http_status(:forbidden)
      end

  end

  
describe "POST /tasks" do
  let(:token) do
    JsonWebToken.encode(user_id: user.id)
  end

  it "creates a task with valid parameters" do
    expect {
      post "/tasks",
           params: {
             task: {
               title: "Learn RSpec",
               completed: false
             }
           },
           headers: {
             "Authorization" => "Bearer #{token}"
           },
           as: :json
    }.to change(Task, :count).by(1)

    expect(response).to have_http_status(:created)

    json = JSON.parse(response.body)
    expect(json.dig("task", "title")).to eq("Learn RSpec")
  end

  it "rejects a task with a blank title" do
  expect {
    post "/tasks",
         params: {
           task: {
             title: "",
             completed: false
           }
         },
         headers: {
           "Authorization" => "Bearer #{token}"
         },
         as: :json
  }.not_to change(Task, :count)

  expect(response).to have_http_status(:unprocessable_content)
end

end

describe "PATCH /tasks/:id" do
  let(:token) do
    JsonWebToken.encode(user_id: user.id)
  end

  it "updates the owner's task" do
    task = Task.create!(
      title: "Old title",
      completed: false,
      user: user
    )

    patch "/tasks/#{task.id}",
          params: {
            task: {
              title: "Updated title"
            }
          },
          headers: {
            "Authorization" => "Bearer #{token}"
          },
          as: :json

    expect(response).to have_http_status(:ok)
    expect(task.reload.title).to eq("Updated title")
  end
end 


describe "DELETE /tasks/:id" do
  let(:token) do
    JsonWebToken.encode(user_id: user.id)
  end

  it "allows an admin to delete a task" do
    task = Task.create!(
      title: "Task to delete",
      completed: false,
      user: user
    )

    admin_token = JsonWebToken.encode(user_id: admin_user.id)

    expect {
      delete "/tasks/#{task.id}",
             headers: {
               "Authorization" => "Bearer #{admin_token}"
             }
    }.to change(Task, :count).by(-1)

    expect(response).to have_http_status(:ok)
  end
end

end
