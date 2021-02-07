if 0 == 0
  p(42)
else
  p(43)
end

i = 0
while i < 10
  p(i)
  i = i + 1
end

i = 10
begin
  p(i)
  i = i - 1
end while i > 0
