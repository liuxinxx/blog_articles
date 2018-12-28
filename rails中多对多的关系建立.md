```
tags:rails
```
```ruby
class Book < ActiveRecord::Base
  has_many :book_tags
  has_many :tags, through: :book_tags
end

class Tag < ActiveRecord::Base
  has_many :book_tags
  has_many :books, through: :book_tags
end

class BookTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :book
end

book = Book.create
tag = Tag.create
book.tags << tag || tag.books << book
```