class NotesController < ApplicationController
  def index
    @notes = Note.all
    render json: @notes
  end

  def create
    @note = Note.new(note_params)

    if @note.save
      render json: @note, status: :created, location: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def show
    @note = Note.find(params[:id])
    render json: @note
  end

  private

  def note_params
    params.expect(note: [ :title, :content, :is_public, :category_id ])
  end
end
