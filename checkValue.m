function is_valid = checkValue(x)

is_valid = true;

if x > 1024
    x = mod(x,1024);
end
if (x-512) >= 0 && (x-768) < 0 && (x-640) >= 0
    is_valid = false;
    return
end

if x > 512
    x = mod(x,512);
end
if (x-256) >= 0 && (x-384) < 0 && (x-320) >= 0
    is_valid = false;
    return
end

if x > 64
    x = mod(x,64);
end
if (x-32) >= 0 && (x-48) < 0 && (x-40) >= 0
    is_valid = false;
    return
end

if x > 32
    x = mod(x,32);
end
if (x-16) >= 0 && (x-24) < 0 && (x-20) >= 0
    is_valid = false;
    return
end