require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "belongs to category" do
    note = notes(:one)
    assert_respond_to note, :category
    assert_equal categories(:one), note.category
  end

  test "is invalid without category" do
    note = Note.new(title: "Test", content: "Content")
    assert_not note.valid?
    assert_includes note.errors[:category], "must exist"
  end

  test "is valid with category" do
    note = Note.new(title: "Test", content: "Content", category: categories(:one))
    assert note.valid?
  end

  test "can be created with minimal attributes" do
    note = Note.new(category: categories(:one))
    assert note.save
  end

  test "stores title" do
    note = notes(:one)
    assert_equal "Introdução ao Rails", note.title
  end

  test "stores content" do
    note = notes(:one)
    assert_equal "Aprenda os fundamentos do Rails", note.content
  end

  test "stores is_public flag" do
    assert notes(:one).is_public
    assert_not notes(:two).is_public
  end
end
