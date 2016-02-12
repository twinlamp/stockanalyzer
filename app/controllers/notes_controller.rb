class NotesController < ApplicationController
  def create
    if @note = Note.create(note_params)
      respond_to do |format|
        format.js { render :layout => false }
      end
    end
  end

  def edit
    @note = Note.find(params[:id])
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def update
    @note = Note.find(params[:id])
    if @note.update_attributes(note_params)
      respond_to do |format|
        format.js { render :layout => false }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private
    def note_params
      params.require(:note).permit(:body, :title, :stock_id, :earning_id)
    end
end