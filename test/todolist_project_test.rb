require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/todolist_project'

class TodoListTest < MiniTest::Test
  def setup
    @todo1 = Todo.new('Buy milk')
    @todo2 = Todo.new('Clean room')
    @todo3 = Todo.new('Go to gym')
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  def test_to_a
    assert_instance_of(Array, @list.to_a)
    assert_equal(@todos, @list.to_a)
  end

  def test_size
    assert_kind_of(Integer, @list.size)
    assert_equal(@todos.size, @list.size)
    assert_equal(3, @list.size)
  end

  def test_first
    assert_equal(@todo1, @list.first)
  end

  def test_last
    assert_equal(@todo3, @list.last)
  end

  def test_shift
    assert_equal(@todo1, @list.shift)
    assert_equal(2, @list.size)
    refute_includes(@list.to_a, @todo1)
    assert_equal([@todo2, @todo3], @list.to_a)
  end

  def test_pop
    assert_equal(@todo3, @list.pop)
    assert_equal([@todo1, @todo2], @list.to_a)
  end

  def test_done_question
    assert_equal(false, @list.done?)
    refute(@list.done?)
    @list.mark_all_done
    assert(@list.done?)
    @list.mark_all_undone
    refute(@list.done?)
    @list.mark_done_at(1)
    refute(@list.done?)
    @list.mark_done_at(0)
    @list.mark_done_at(2)
    assert(@list.done?)
    assert_equal(true, @list.done?)
  end

  def test_add_raise_error
    assert_raises(TypeError) { @list.add(1) }
    assert_raises(TypeError) { @list.add('str') }
    assert_raises(TypeError) { @list.add([1]) }
  end

  def test_add
    todo = Todo.new('Jump around')
    assert_equal(@todos << todo, (@list << todo).to_a)
    assert_includes(@list, todo)
  end

  def test_add_alias
    todo = Todo.new('Wear a hat')
    @list.add(todo)
    @todos << todo
    assert_equal(@todos, @list.to_a)
    assert_includes(@list, todo)
  end

  def test_item_at_raise_error
    assert_raises(IndexError) { @list.item_at(3) }
    assert_raises(IndexError) { @list.item_at(-4) }
    assert_raises(ArgumentError) { @list.item_at }
  end

  def test_item_at
    assert_equal(@todo1, @list.item_at(0))
    assert_equal(@todo2, @list.item_at(1))
    assert_equal(@todo3, @list.item_at(-1))
  end

  def test_mark_done_at
    assert_raises(IndexError) { @list.mark_done_at(3) }
    assert_raises(IndexError) { @list.mark_done_at(-4) }
    assert_raises(ArgumentError) { @list.mark_done_at }
    @list.mark_done_at(1)
    assert_equal(false, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end

  def test_mark_undone_at
    assert_raises(IndexError) { @list.mark_undone_at(3) }
    assert_raises(IndexError) { @list.mark_undone_at(-4) }
    assert_raises(ArgumentError) { @list.mark_undone_at }
    assert_equal(true, @todo1.undone?)
    @list.mark_done_at(0)
    assert_equal(false, @todo1.undone?)
    @list.mark_undone_at(0)
    assert_equal(true, @todo1.undone?)
    assert_equal(true, @todo2.undone?)
  end

  def test_done_bang
    assert_equal(false, @list.done?)
    @list.done!
    assert_equal(true, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(true, @todo3.done?)
    assert_equal(true, @list.done?)
  end

  def test_mark_all_done
    assert_equal(false, @list.done?)
    @list.mark_all_done
    assert_equal(true, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(true, @todo3.done?)
    assert_equal(true, @list.done?)
  end

  def test_remove_at
    assert_raises(IndexError) { @list.remove_at(3) }
    assert_raises(IndexError) { @list.remove_at(-4) }
    assert_raises(ArgumentError) { @list.remove_at }
    assert_equal(@todo2, @list.remove_at(1))
    assert_equal([@todo1, @todo3], @list.to_a)
  end

  def test_to_s
    assert_instance_of(String, @list.to_s)
    assert(@list.to_s.start_with?("---- #{@list.title} ----"))
    assert_includes(@list.to_s, @todo1.to_s)
    assert_includes(@list.to_s, @todo2.to_s)
    assert_includes(@list.to_s, @todo3.to_s)

    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [ ] Buy milk
    [ ] Clean room
    [ ] Go to gym
    OUTPUT

    assert_equal(output, @list.to_s)
  end

  def test_to_s_2
    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [ ] Buy milk
    [X] Clean room
    [ ] Go to gym
    OUTPUT

    @list.mark_done_at(1)
    assert_equal(output, @list.to_s)
  end

  def test_to_s_3
    output = <<~OUTPUT.chomp
    ---- Today's Todos ----
    [X] Buy milk
    [X] Clean room
    [X] Go to gym
    OUTPUT

    @list.done!
    assert_equal(output, @list.to_s)
  end

  def test_each
    # assert_equal(@list.to_enum, @list.each)
    result = []
    @list.each { |todo| result << todo }
    assert_equal([@todo1, @todo2, @todo3], result)
  end

  def test_each_2
    assert_equal(@list, @list.each(&:itself))
  end

  def test_select
    @list.mark_done_at(1)
    assert_equal([@todo1, @todo3], @list.select(&:undone?).to_a)
    @list.mark_done_at(0)
    assert_equal([@todo1, @todo2], @list.select(&:done?).to_a)
    assert_equal([], @list.select(&:nil?).to_a)

    list = TodoList.new(@list.title)
    list << @todo3
    assert_equal(list, @list.select(&:undone?))
  end

  def test_setup
    assert_equal(@list.title, "Today's Todos")
    assert_equal(@list.item_at(0).title, 'Buy milk')
    assert_equal(@list.item_at(2).description, '')
  end

  def test_add_at
    todo = Todo.new('Eat a pie')
    assert_raises(TypeError) { @list.add_at(1, 'str') }
    assert_raises(IndexError) { @list.add_at(4, todo) }
    assert_equal([*@todos, todo], @list.add_at(3, todo).to_a)
  end

  def test_all_done
    list = TodoList.new(@list.title)
    assert_equal(list, @list.all_done)
    list << @todo1
    list.mark_done_at(0)
    assert_equal(list, @list.all_done)
  end

  def test_all_not_done
    list = @list.dup
    assert_equal(list, @list.all_not_done)
    list.remove_at(1)
    @todo2.done!
    assert_equal(list, @list.all_not_done)
  end

  def test_find_by_title
    assert_raises(TypeError) { @list.find_by_title(123) }
    assert_equal(@todo2, @list.find_by_title('room'))
    assert_equal(@todo2, @list.find_by_title('ROoM'))
    assert_nil(@list.find_by_title('crazy'))
  end

  def test_include_question
    assert_equal(@todos.include?(@todo1), @list.include?(@todo1))
  end

  def test_mark_done
    assert_raises(TypeError) { @list.mark_done([]) }
    @list.mark_done('gym')
    refute(@todo1.done?)
    assert(@todo3.done?)
  end

  def test_mark_undone
    assert_raises(TypeError) { @list.mark_undone({}) }
    @list.mark_undone('gym')
    assert_equal(true, @todo3.undone?)
    @list.mark_done('gym')
    assert_equal(true, @todo3.done?)
    @list.mark_undone('gym')
    assert_equal(true, @todo3.undone?)
  end

  def test_rename_title
    assert_raises(TypeError) { @list.rename_title(3.0) }
    @list.rename_title('New list')
    assert_equal('New list', @list.title)
  end

  def test_undone_bang
    @list.done!
    assert_equal(true, @list.done?)
    @list.undone!
    assert_equal(false, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end

  def test_undone_bang_alias
    @list.done!
    assert_equal(true, @list.done?)
    @list.mark_all_undone
    assert_equal(false, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end

  def test_update_description
    assert_raises(TypeError) { @list.update_description(42, 'str') }
    assert_raises(TypeError) { @list.update_description('str', []) }
    @list.update_description('milk', 'Vons')
    assert_equal('Vons', @todo1.description)
  end

  def test_initialize
    list = TodoList.new('Test todos')
    assert_equal('Test todos', list.title)
    assert_equal([], list.to_a)
  end

  def test_check_bounds
    assert_raises(IndexError) { @list.send(:check_bounds, 4) }
    assert_raises(IndexError) { @list.send(:check_bounds, 100) }
    assert_equal(true, @list.send(:check_bounds, 1) )
    assert_equal(true, @list.send(:check_bounds, 3) )
    assert_equal(true, @list.send(:check_bounds, -3) )
  end

  def test_check_string
    assert_raises(TypeError) { @list.send(:check_string, []) }
    assert_raises(TypeError) { @list.send(:check_string, 1) }
    assert_raises(TypeError) { @list.send(:check_string, {}) }
    assert_raises(TypeError) { @list.send(:check_string, 3.0) }
    assert_raises(TypeError) { @list.send(:check_string, :yo) }
    assert_equal(true, @list.send(:check_string, '') )
    assert_equal(true, @list.send(:check_string, 'abc') )
  end

  def test_check_validity
    assert_raises(TypeError) { @list.send(:check_validity, []) }
    assert_raises(TypeError) { @list.send(:check_validity, 'abc') }
    assert_raises(TypeError) { @list.send(:check_validity, 123) }
    assert_equal(true, @list.send(:check_validity, Todo.new('dance a lot')))
  end

  def test_index
    assert_equal(0, @list.send(:index, @todo1))
    assert_equal(1, @list.send(:index, @todo2))
    assert_equal(2, @list.send(:index, @todo3))
    assert_nil(@list.send(:index, @todo4))
  end

  def test_mark_title
    @list.send(:mark_title, 'gym', done: true)
    assert_equal(true, @todo3.done?)
    @list.send(:mark_title, 'gym', done: false)
    assert_equal(false, @todo3.done?)
    not_found_msg = "No item found with 'taco' in its title."
    assert_equal(not_found_msg, @list.send(:mark_title, 'taco', done: true))
    assert_equal(not_found_msg, @list.send(:mark_title, 'taco', done: false))
  end

  def test_unshift
    todo = Todo.new('Unshift this')
    list = TodoList.new(@list.title)
    list << todo << @todo1 << @todo2 << @todo3
    assert_equal(list, @list.unshift(todo))
  end
end
