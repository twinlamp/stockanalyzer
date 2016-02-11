require 'rails_helper'

RSpec.describe NotesController, :type => :controller do
  describe "POST create" do
    context "valid attributes" do
      it "creates a new Note" do
        stock = FactoryGirl.create(:stock)
        expect {
          xhr :post, :create, { note: attributes_for(:note).merge(stock_id: stock.id) }
        }.to change(Note, :count).by(1)
      end
    end
    context "invalid attributes" do
      it "does not create a new Note" do
        stock = FactoryGirl.create(:stock)
        expect {
          xhr :post, :create, { note: attributes_for(:note, title: nil).merge(stock_id: stock.id) }
        }.to_not change(Note, :count)
      end
    end
  end

  describe "DELETE destroy" do
    it "removes a Note" do
      note = FactoryGirl.create(:note)
      expect {
        xhr :delete, :destroy, { id: note.id }
      }.to change(Note, :count).by(-1)
    end
  end

  describe "PATCH update" do
    context "valid attributes" do
      it "changes note's attributes" do
        note = FactoryGirl.create(:note)
        xhr :patch, :update, { id: note.id, note: attributes_for(:note, title: 'temp', body: 'temp') }
        note.reload
        expect(note.title).to eq('temp')
        expect(note.body).to eq('temp')
      end
    end
    context "invalid attributes" do
      it "does not change note's attributes" do
        note = FactoryGirl.create(:note)
        expect {
          xhr :patch, :update, { id: note.id, note: attributes_for(:note, title: '', body: '') }
          note.reload
        }.to_not change{note.title}
      end
    end
  end
end
