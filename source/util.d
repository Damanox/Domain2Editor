module util;

import std.range;

T readModel(T)(ref ubyte[] range, int ver = 1)
{
    T res;
    res.read(range, ver);
    return res;
}

void writeModel(T)(ref Appender!(const(ubyte)[]) range, T model, int ver = 1)
{
    model.write(range, ver);
}
