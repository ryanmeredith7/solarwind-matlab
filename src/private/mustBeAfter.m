function mustBeAfter(date, year)
    tz = date.TimeZone;
    assert(date >= datetime(year, 1, 1, "TimeZone", tz), ...
        "Must be after %4i.", year);
end
