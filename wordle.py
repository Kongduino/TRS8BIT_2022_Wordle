def cmpAV(a, v):
  a = list(a.upper())
  v = list(v.upper())
  r = list("*****")
  for i in range(0,5):
    # look for exact matches first
    c = v[i]
    print(f"is {c} = {a[i]}? {c == a[i]}")
    if c == a[i]:
      # it's a match
      r[i] = c # r = response
      v[i] = '_' # invalidate this char
      a[i] = '_' # invalidate this char
      print(f"  r is now {''.join(r)}")
  print(f"r = {''.join(r)}")
  print(f"a = {''.join(a)}")
  print(f"v = {''.join(v)}")
  for i in range(0,5):
    # look for close matches next
    if r[i] == '*':
      # if this char hasn't been invalidated yet
      c = v[i].upper()
      print(f"Dealing with {c}, position {i}")
      for j in range(0,5):
        if i != j:
          # if it's not the same position: we have done that already
          print(f"  is {c} = {a[j]} [{j}]? {c == a[j]}")
          if c == a[j]:
            # close match
            c = c.lower()
            r[i] = c
            print(f"    r is now {''.join(r)}")
            break  
  return(''.join(r))

cmpAV("STILL", "SLITS")
cmpAV("STILL", "SLATS")
cmpAV("STILL", "STALL")
cmpAV("STILL", "PILES")
cmpAV("LIGHT", "SKILL")
cmpAV("LIGHT", "TACET")

