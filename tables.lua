function removeFirst(table)
    return del(table, table[1])
end

function shuffle(t)
    -- do a fisher-yates shuffle
    for i = #t, 1, -1 do
      local j = flr(rnd(i)) + 1
      swap(t, i, j)
    end
end

function swap(t, i, j)
    t[i], t[j] = t[j], t[i]
end