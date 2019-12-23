assert "nil" do
  segment = Seg.new(nil)

  assert_equal segment.prev, ""
  assert_equal segment.curr, "/"
  assert_true segment.root?
end

assert "root" do
  segment = Seg.new("/")

  assert_equal segment.prev, ""
  assert_equal segment.curr, "/"
  assert_true segment.root?
end

assert "init" do
  segment = Seg.new("/")

  assert_true segment.init?
  assert_true segment.root?

  segment = Seg.new("/foo")

  assert_true segment.init?
  assert_true !segment.root?

  assert_equal segment.extract, "foo"

  assert_true !segment.init?
  assert_true segment.root?
end

assert "extract" do
  segment = Seg.new("/foo/bar/baz")

  assert_equal segment.extract, "foo"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.extract, "bar"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert_true !segment.root?

  assert_equal segment.extract, "baz"
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?

  assert_equal segment.extract, nil
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?
end

assert "retract" do
  segment = Seg.new("/foo/bar/baz")

  3.times { segment.extract }

  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""

  assert_equal segment.retract, "baz"
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert_true !segment.root?

  assert_equal segment.retract, "bar"
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.retract, "foo"
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?

  assert_equal segment.retract, nil
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?
end

assert "consume" do
  segment = Seg.new("/foo/bar/baz")

  assert_equal segment.consume("bar"), false
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?

  assert_equal segment.consume("fo"), false
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?

  assert_equal segment.consume("foo"), true
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.consume("foo"), false
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.consume("bar"), true
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert_true !segment.root?

  assert_equal segment.consume("baz"), true
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?

  assert_equal segment.consume("baz"), false
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?
end

assert "restore" do
  segment = Seg.new("/foo/bar/baz")

  3.times { segment.extract }

  assert_equal segment.restore("foo"), false
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?

  assert_equal segment.restore("baz"), true
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert_true !segment.root?

  assert_equal segment.restore("bar"), true
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.restore("foo"), true
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?

  assert_equal segment.restore("foo"), false
  assert_equal segment.prev, ""
  assert_equal segment.curr, "/foo/bar/baz"
  assert_true !segment.root?
end

assert "capture" do
  segment = Seg.new("/foo/bar/baz")

  captures = {}

  assert_equal segment.capture(:c1, captures), true
  assert_equal segment.prev, "/foo"
  assert_equal segment.curr, "/bar/baz"
  assert_true !segment.root?

  assert_equal segment.capture(:c2, captures), true
  assert_equal segment.prev, "/foo/bar"
  assert_equal segment.curr, "/baz"
  assert_true !segment.root?

  assert_equal segment.capture(:c3, captures), true
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?

  assert_equal segment.capture(:c4, captures), false
  assert_equal segment.prev, "/foo/bar/baz"
  assert_equal segment.curr, ""
  assert_true segment.root?

  assert_equal "foo", captures[:c1]
  assert_equal "bar", captures[:c2]
  assert_equal "baz", captures[:c3]
  assert_equal nil, captures[:c4]
end
