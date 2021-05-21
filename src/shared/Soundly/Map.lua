return function(value, minA, maxA, minB, maxB)
    return (maxB - minB) * (value - minA) / (maxA - minA) + minB;
end