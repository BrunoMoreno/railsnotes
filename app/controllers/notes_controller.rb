class NotesController < ApplicationController
  def index
    @notes = Current.user.notes
    render json: @notes
  end

  def create
    @note = Current.user.notes.new(note_params)

    if @note.save
      render json: @note, status: :created, location: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def show
    @note = Current.user.notes.find(params[:id])
    render json: @note
  end

  def update
    @note = Current.user.notes.find(params[:id])

    if @note.update(note_params)
      render json: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @note = Current.user.notes.find(params[:id])
    @note.destroy
    head :no_content
  end

  private

  def note_params
    params.expect(note: [ :title, :content, :is_public, :category_id ])
  end
end
