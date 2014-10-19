module models;

import std.bitmanip;
import std.system;
import std.range;
import std.math;
import std.algorithm;
import util;

struct DataStruct
{
    public uint signature;
    public float speed;
    public Domain[] domains;
    public Time[] times;
    public int unk;
    public bool loaded;

    public void read(ref ubyte[] buffer, int ver = 1)
    {
        signature = buffer.read!(uint, Endian.littleEndian);
        speed = buffer.read!(float, Endian.littleEndian);
        auto count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            domains ~= buffer.readModel!Domain(ver);
        count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            times ~= buffer.readModel!Time();
        unk = buffer.read!(int, Endian.littleEndian);
        loaded = true;
    }

    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(uint, Endian.littleEndian)(signature);
        buffer.append!(float, Endian.littleEndian)(speed);
        buffer.append!(int, Endian.littleEndian)(domains.length);
        foreach(domain; domains)
            buffer.writeModel(domain, ver);
        buffer.append!(int, Endian.littleEndian)(times.length);
        foreach(time; times)
            buffer.writeModel(time);
        buffer.append!(int, Endian.littleEndian)(unk);
    }
}

struct SevStruct
{
    public DomainSev[] domains;

    this(DataStruct data)
    {
        foreach(domain; data.domains)
            domains ~= DomainSev(domain);
        calculateTimes(data.speed, data.domains);
    }
    
    public void read(ref ubyte[] buffer, int ver = 1)
    {
        auto count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            domains ~= buffer.readModel!DomainSev(ver);
    }
    
    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(int, Endian.littleEndian)(domains.length);
        foreach(domain; domains)
            buffer.writeModel(domain, ver);
    }

    void calculateTimes(float speed, Domain[] base)
    {
        foreach(ref domain; domains)
        {
            foreach(ref touch; domain.touchDomains)
            {
                auto baseDomain = base.find!((a,b) => a.id == b)(domain.id)[0];
                auto touchDomain = base.find!((a,b) => a.id == b)(touch.id)[0];
                auto dist = sqrt(pow(cast(float)(touchDomain.x - baseDomain.x), 2) + pow(cast(float)(touchDomain.y - baseDomain.y), 2));
                touch.time = cast(int)(dist / speed);
            }
        }
    }
}

struct Domain
{
    public immutable (wchar)[] name;
    public uint id;
    public int points;
    public int battleType;
    public int owner;
    public int capital;
    public DomainPoint[] spawnPoints;
    public int x;
    public int y;
    public Unk[] unks;
    public DomainPoint[] unks2;
    public uint[] touchDomains;

    public void read(ref ubyte[] buffer, int ver = 1)
    {
        for(auto i = 0; i < 16; i++)
            name ~= buffer.read!(wchar, Endian.littleEndian);
        id = buffer.read!(uint, Endian.littleEndian);
        points = buffer.read!(int, Endian.littleEndian);
        battleType = buffer.read!(int, Endian.littleEndian);
        owner = buffer.read!(int, Endian.littleEndian);
        capital = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < 4; i++)
            spawnPoints ~= buffer.readModel!DomainPoint(ver);
        x = buffer.read!(int, Endian.littleEndian);
        y = buffer.read!(int, Endian.littleEndian);

        auto count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            unks ~= buffer.readModel!Unk(ver);
        
        count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            unks2 ~= buffer.readModel!DomainPoint(ver);
        
        count = buffer.read!(int, Endian.littleEndian);
        for (auto i = 0; i < count; i++)
            touchDomains ~= buffer.read!(uint, Endian.littleEndian);
    }

    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        for(auto i = 0; i < 16; i++)
            buffer.append!(wchar, Endian.littleEndian)(name[i]);
        buffer.append!(uint, Endian.littleEndian)(id);
        buffer.append!(int, Endian.littleEndian)(points);
        buffer.append!(int, Endian.littleEndian)(battleType);
        buffer.append!(int, Endian.littleEndian)(owner);
        buffer.append!(int, Endian.littleEndian)(capital);
        foreach(point; spawnPoints)
            buffer.writeModel(point, ver);
        buffer.append!(int, Endian.littleEndian)(x);
        buffer.append!(int, Endian.littleEndian)(y);
        buffer.append!(int, Endian.littleEndian)(unks.length);
        foreach(point; unks)
            buffer.writeModel(point, ver);
        buffer.append!(int, Endian.littleEndian)(unks2.length);
        foreach(point; unks2)
            buffer.writeModel(point, ver);
        buffer.append!(int, Endian.littleEndian)(touchDomains.length);
        foreach(domain; touchDomains)
            buffer.append!(uint, Endian.littleEndian)(domain);
    }
}

struct DomainSev
{
    public uint id;
    public int points;
    public int battleType;
    public int owner;
    public int capital;
    public DomainPoint[] spawnPoints;
    public TouchDomain[] touchDomains;

    this(Domain domain)
    {
        id = domain.id;
        points = domain.points;
        battleType = domain.battleType;
        owner = domain.owner;
        capital = domain.capital;
        spawnPoints = domain.spawnPoints;
        foreach(id; domain.touchDomains)
            touchDomains ~= TouchDomain(id);
    }
    
    public void read(ref ubyte[] buffer, int ver = 1)
    {
        id = buffer.read!(uint, Endian.littleEndian);
        points = buffer.read!(int, Endian.littleEndian);
        battleType = buffer.read!(int, Endian.littleEndian);
        owner = buffer.read!(int, Endian.littleEndian);
        capital = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < 4; i++)
            spawnPoints ~= buffer.readModel!DomainPoint(ver);

        auto count = buffer.read!(int, Endian.littleEndian);
        for(auto i = 0; i < count; i++)
            touchDomains ~= TouchDomain(buffer.read!(uint, Endian.littleEndian));
        for (auto i = 0; i < count; i++)
            touchDomains[i].time = buffer.read!(int, Endian.littleEndian);
    }
    
    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(uint, Endian.littleEndian)(id);
        buffer.append!(int, Endian.littleEndian)(points);
        buffer.append!(int, Endian.littleEndian)(battleType);
        buffer.append!(int, Endian.littleEndian)(owner);
        buffer.append!(int, Endian.littleEndian)(capital);
        foreach(point; spawnPoints)
            buffer.writeModel(point, ver);
        buffer.append!(int, Endian.littleEndian)(touchDomains.length);
        foreach(domain; touchDomains)
            buffer.append!(uint, Endian.littleEndian)(domain.id);
        foreach(domain; touchDomains)
            buffer.append!(int, Endian.littleEndian)(domain.time);
    }
}

struct DomainPoint
{
    public float x;
    public float y;
    public float z;

    public void read(ref ubyte[] buffer, int ver = 1)
    {
        x = buffer.read!(float, Endian.littleEndian);
        y = buffer.read!(float, Endian.littleEndian);
        z = buffer.read!(float, Endian.littleEndian);
    }
    
    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(float, Endian.littleEndian)(x);
        buffer.append!(float, Endian.littleEndian)(y);
        buffer.append!(float, Endian.littleEndian)(z);
    }
}

struct TouchDomain
{
    public uint id;
    public int time;
}

struct Unk
{
    public float x;
    public float y;

    public void read(ref ubyte[] buffer, int ver = 1)
    {
        x = buffer.read!(float, Endian.littleEndian);
        y = buffer.read!(float, Endian.littleEndian);
    }
    
    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(float, Endian.littleEndian)(x);
        buffer.append!(float, Endian.littleEndian)(y);
    }
}

struct Time
{
    public int day;
    public int hour;
    public int minute;
    
    public void read(ref ubyte[] buffer, int ver = 1)
    {
        day = buffer.read!(int, Endian.littleEndian);
        hour = buffer.read!(int, Endian.littleEndian);
        minute = buffer.read!(int, Endian.littleEndian);
    }
    
    public void write(ref Appender!(const(ubyte)[]) buffer, int ver = 1)
    {
        buffer.append!(int, Endian.littleEndian)(day);
        buffer.append!(int, Endian.littleEndian)(hour);
        buffer.append!(int, Endian.littleEndian)(minute);
    }
}
