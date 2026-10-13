  require 'rails_helper'

  RSpec.describe TaskPolicy do
    let(:owner) { User.create!(name: 'Deena', email: 'deena803@gmail.com', role: 'user') }
    let(:another_user) { User.create!(name: 'Praba', email: 'praba@gmail.com', role: 'user')  }
    let(:admin_user) { User.create!(name: 'Rachu', email: 'Rachu@gmail.com', role: 'admin') }
    let(:task) { Task.create!(title: 'test', completed: true, user: owner) }

    describe "Show" do
      it "allow user to view own record" do
        expect(described_class.new(owner, task).show?).to be true
      end

      it "Deny user to view other user record" do
        expect(described_class.new(another_user, task).show?).to be false
      end

      it "allow admin to view other user record" do
        expect(described_class.new(admin_user, task).show?).to be true
      end
    end 
   
    describe "Update" do
      it "allow user to update own record" do
        expect(described_class.new(owner, task).update?).to be true
      end

      it "Deny user to update other user record" do
        expect(described_class.new(another_user, task).update?).to be false
      end

      it "allow admin to update other user record" do
        expect(described_class.new(admin_user, task).update?).to be true
      end
    end 

    describe "Destroy" do
      it "Deny user to destroy own record" do
        expect(described_class.new(owner, task).destroy?).to be false 
      end

      it "Deny user to destroy other user record" do
        expect(described_class.new(another_user, task).destroy?).to be false
      end

      it "allow admin to destroy other user record" do
        expect(described_class.new(admin_user, task).destroy?).to be true
      end
    end 

    describe TaskPolicy::Scope do
    it "returns only the owner's tasks for a normal user" do
      user = User.create!(
        name: 'Deena',
        email: 'deena803@gmail.com',
        password: 'password123',
        role: 'user'
      )

      other_user = User.create!(
        name: 'Praba',
        email: 'praba@gmail.com',
        password: 'password123',
        role: 'user'
      )

      own_task = Task.create!(
        title: 'My task',
        completed: false,
        user: user
      )

      Task.create!(
        title: 'Other task',
        completed: false,
        user: other_user
      )

      result = described_class.new(user, Task.all).resolve

      expect(result).to contain_exactly(own_task)
    end

     it "returns all tasks for admin user" do
      user = User.create!(
        name: 'Deena',
        email: 'deena803@gmail.com',
        password: 'password123',
        role: 'user'
      )

      other_user = User.create!(
        name: 'Praba',
        email: 'praba@gmail.com',
        password: 'password123',
        role: 'user'
      )

      admin = User.create!(
        name: 'Rachu',
        email: 'rachu@gmail.com',
        password: 'password123',
        role: 'admin'
      )

      own_task = Task.create!(
        title: 'My task',
        completed: false,
        user: user
      )

      other_task = Task.create!(
        title: 'Other task',
        completed: false,
        user: other_user
      )

      result = described_class.new(admin, Task.all).resolve

      expect(result).to contain_exactly(own_task, other_task)
    end
  end
end   