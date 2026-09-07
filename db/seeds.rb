# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
# Create default categories used by the application.
["work", "programming", "personal", "games", "movies"].each do |category_title|
  category = Category.find_or_create_by!(title: category_title)

  case category_title
  when "work"
    Note.find_or_create_by!(title: "Weekly planning", content: "Review priorities and plan the week.", category: category)
    Note.find_or_create_by!(title: "Inbox cleanup", content: "Sort pending tasks and archive old notes.", category: category)
  when "programming"
    Note.find_or_create_by!(title: "Rails ideas", content: "Explore a better search feature for notes.", category: category)
    Note.find_or_create_by!(title: "Bug list", content: "Document the current issues to fix in the next sprint.", category: category)
  when "personal"
    Note.find_or_create_by!(title: "Groceries", content: "Milk, eggs, vegetables, and coffee beans.", category: category)
    Note.find_or_create_by!(title: "Self-care", content: "Schedule time to rest and exercise this week.", category: category)
  when "games"
    Note.find_or_create_by!(title: "Game night", content: "Invite friends for the weekend co-op session.", category: category)
    Note.find_or_create_by!(title: "Wishlist", content: "Save the games to try next on Steam and Switch.", category: category)
  when "movies"
    Note.find_or_create_by!(title: "Watchlist", content: "Movies and series to watch when there is time.", category: category)
    Note.find_or_create_by!(title: "Favorites", content: "Keep a short list of films worth rewatching.", category: category)
  end
end

