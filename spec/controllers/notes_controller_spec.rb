require 'rails_helper'

RSpec.describe NotesController, :type => :controller do
  describe "POST create" do
    context "valid attributes" do
      it "creates a new Note" do
        stock = FactoryGirl.create(:stock)
        xhr :post, :create, { note: attributes_for(:note).merge(stock_id: stock.id) }
        expect(Note.count).to eq(1)
      end
    end
    context "invalid attributes" do
      it "does not create a new Note" do
        stock = FactoryGirl.create(:stock)
        xhr :post, :create, { note: attributes_for(:note, title: nil).merge(stock_id: stock.id) }
        expect(Note.count).to eq(0)
      end
    end
  end

  describe "DELETE destroy" do
    it "removes a Note" do
      note = FactoryGirl.create(:note)
      xhr :delete, :destroy, { id: note.id }
      expect(Note.count).to eq(0)
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
        title = note.title
        xhr :patch, :update, { id: note.id, note: attributes_for(:note, title: '', body: '') }
        note.reload
        expect(note.title).to eq(title)
      end
    end
  end
end
