# frozen_string_literal: true

# This class represents a todo item and its associated
# data: name and description. There's also a "done"
# flag to show whether this todo item is done.

class Todo
  DONE_MARKER = 'X'
  UNDONE_MARKER = ' '

  attr_accessor :title, :description

  def initialize(title, description = '')
    @title = title
    @description = description
    @done = false
  end

  def done!
    self.done = true
  end

  def done?
    done
  end

  def undone?
    !done?
  end

  def undone!
    self.done = false
  end

  def to_s
    "[#{done? ? DONE_MARKER : UNDONE_MARKER}] #{title}"
  end

  private

  attr_accessor :done
end

# This class represents a collection of Todo objects.
# You can perform typical collection-oriented actions
# on a TodoList object, including iteration and selection.

class TodoList
  attr_reader :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def ==(other)
    todos == other.todos
  end

  def add(todo)
    check_validity(todo)
    todos << todo
    self
  end
  alias << add

  def add_at(idx, todo)
    check_validity(todo)
    check_bounds(idx)
    todos.insert(idx, todo)
    self
  end

  def all_done
    select(&:done?)
  end

  def all_not_done
    select(&:undone?)
  end

  def done!
    each(&:done!)
  end
  alias mark_all_done done!

  def done?
    todos.all?(&:done?)
  end

  def each
    return to_enum unless block_given?
    todos.each { |todo| yield(todo) }
    self
  end

  def find_by_title(todo_title)
    check_string(todo_title)
    select { |todo| todo.title =~ /#{todo_title}/i }.first
  end

  def first
    todos.first
  end

  def include?(todo)
    todos.include?(todo)
  end

  def item_at(idx)
    todos.fetch(idx)
  end

  def mark_done(todo_title)
    mark_title(todo_title, done: true)
  end

  def mark_done_at(idx)
    item_at(idx).done!
  end

  def mark_undone(todo_title)
    mark_title(todo_title, done: false)
  end

  def mark_undone_at(idx)
    item_at(idx).undone!
  end

  def last
    todos.last
  end

  def pop
    todos.pop
  end

  def remove_at(idx)
    todos.delete_at(idx) if item_at(idx)
  end

  def rename_title(str)
    check_string(str)
    self.title = str
  end

  def select
    return to_enum(:select) unless block_given?
    selected_list = TodoList.new(title)
    each { |todo| selected_list << todo if yield(todo) }
    selected_list
  end

  def shift
    todos.shift
  end

  def size
    todos.size
  end

  def to_a
    todos
  end

  def to_s
    ["---- #{title} ----", todos.map(&:to_s)].join("\n")
  end

  def undone!
    each(&:undone!)
  end
  alias mark_all_undone undone!

  def unshift(todo)
    todos.unshift(todo)
    self
  end

  def update_description(todo_title, description)
    check_string(description)
    find_by_title(todo_title).description = description
  end

  protected

  attr_reader :todos

  private

  attr_writer :title

  def check_bounds(idx)
    raise IndexError, "index #{idx} outside of list bounds" unless idx <= size
    true
  end

  def check_string(str)
    raise TypeError, "#{str} is not a String" unless str.is_a?(String)
    true
  end

  def check_validity(todo)
    raise TypeError, 'can only add Todo objects' unless todo.instance_of?(Todo)
    true
  end

  def index(item)
    todos.index(item)
  end

  def mark_title(str, done:)
    matching_idx = index(find_by_title(str))
    if matching_idx
      done ? mark_done_at(matching_idx) : mark_undone_at(matching_idx)
    else
      "No item found with '#{str}' in its title."
    end
  end
end
