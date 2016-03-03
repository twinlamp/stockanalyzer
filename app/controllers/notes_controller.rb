class NotesController < ApplicationController
  
  def create
    @note = Note.new(note_params)
    render layout: false if @note.save
  end

  def update
    @note = Note.find(params[:id])
    render layout: false if @note.update_attributes(note_params)
  end

  def destroy
    @note = Note.find(params[:id])
    render layout: false if @note.destroy
  end

  private
    def note_params
      params.require(:note).permit(:body, :title, :stock_id, :happened_at)
    end
end