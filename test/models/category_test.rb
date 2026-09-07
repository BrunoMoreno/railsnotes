require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "has many notes" do
    category = categories(:one)
    assert_respond_to category, :notes
    assert_kind_of ActiveRecord::Associations::CollectionProxy, category.notes
  end

  test "generates slug from title on create" do
    category = Category.new(title: "Ruby on Rails 8")
    category.valid?
    assert_equal "ruby-on-rails-8", category.slug
  end

  test "generates slug from title with special characters" do
    category = Category.new(title: "C++ & Java!")
    category.valid?
    assert_equal "c-java", category.slug
  end

  test "does not overwrite slug if already present and title unchanged" do
    category = categories(:one)
    original_slug = category.slug
    category.save!
    assert_equal original_slug, category.reload.slug
  end

  test "regenerates slug when title changes" do
    category = categories(:one)
    category.update!(title: "Python")
    assert_equal "python", category.reload.slug
  end

  test "preserves existing slug when title is blank" do
    category = categories(:one)
    original_slug = category.slug
    category.title = nil
    category.valid?
    assert_equal original_slug, category.slug
  end

  test "destroys dependent notes" do
    category = categories(:one)
    Note.create!(title: "Test note", content: "Content", category: category)

    assert_difference "Note.count", -category.notes.count do
      category.destroy!
    end
  end

  test "can be created with valid attributes" do
    category = Category.new(title: "New Category", slug: "new-category")
    assert category.save
  end

  test "can be created without a title" do
    category = Category.new
    assert category.save
  end

  test "can be created without a slug" do
    category = Category.new(title: "Slugless")
    category.slug = nil
    category.valid?
    assert category.save
  end
end
