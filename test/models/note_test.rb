require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "belongs to category" do
    note = notes(:one)
    assert_respond_to note, :category
    assert_equal categories(:one), note.category
  end

  test "belongs to user" do
    note = notes(:one)
    assert_respond_to note, :user
    assert_equal users(:one), note.user
  end

  test "is invalid without category" do
    note = Note.new(title: "Test", content: "Content", user: users(:one))
    assert_not note.valid?
    assert_includes note.errors[:category], "must exist"
  end

  test "is invalid without user" do
    note = Note.new(title: "Test", content: "Content", category: categories(:one))
    assert_not note.valid?
    assert_includes note.errors[:user], "must exist"
  end

  test "is valid with category and user" do
    note = Note.new(title: "Test", content: "Content", category: categories(:one), user: users(:one))
    assert note.valid?
  end

  test "can be created with minimal attributes" do
    note = Note.new(category: categories(:one), user: users(:one))
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
