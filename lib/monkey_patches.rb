###
#Adding a precision option to round floats - 0.9999 can become 0.99 instead of 1
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end