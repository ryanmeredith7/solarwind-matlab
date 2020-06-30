
function mustBeAfter(date, year)
    assert(date >= datetime(year, 1, 1), "Must be after %4i.", year)
end
