$N = 8

def accept? b
  b.length == $N
end

def reject? b
  c = b.each_with_index.map { |j,k| j+k }.uniq
  d = b.each_with_index.map { |j,k| j-k }.uniq
  b.length != c.length || c.length != d.length
end

def backtrack b
  ([*0...$N] - b).each do |i|
    c = b.dup << i
    yield c unless reject? c
  end
end

def output b
  print "\n#{b}\n"
  b.each do |r|
    s = '.' * $N
    s[r] = 'Q'
    print "#{s}\n"
  end
end

def solve b
  if accept? b
    output b
  else
    backtrack( b ) { |c| solve c }
  end
end

solve []
