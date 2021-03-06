# hexascii.py  29/01/2016  D.J.Whale
#
# Provide simple hex literals and conversions

import arrays

# n <- hexascii_fromstr("A3")
# n <- hexascii_fromstr("DEADBEEF")

def fromstr(s):
    """Convert s as a hex string into a number.
    Supports 1,2,3,4 byte numbers."""
    return int(s, base=16)

def tostr(n, bytes=1):
    """convert n into a hex string, honoring the bytes as the max width.
    Note that varargs by default are supported, so this should work."""
    n = n & 0xFFFFFFFF # negative numbers will be two's complement
    if bytes == 1:
        if n > 0xFF:
            raise ValueError("Number too big for a 1 byte number")
        return "%02X" % n
    if bytes == 2:
        if n > 0xFFFF:
            raise ValueError("Number too big for a 2 byte number")
        return "%04X" % n
    if bytes == 3:
        if n > 0xFFFFFF:
            raise ValueError("Number too big for a 3 byte number")
        return "%06X" % n
    if bytes == 4:
        return "%08X" % n
    else:
        raise ValueError("Only bytes=[1..4] supported")

# a <- hexascii_array("A01237EC12120D0A")

def array(s):
    """Convert s as a hex string into an initialised array"""
    if len(s) % 2 != 0:
        s = '0' + s
    l = []
    for i in range(len(s)/2):
        o = i*2
        b = s[o:o+2]
        n = fromstr(b)
        l.append(n)
    return arrays.Array(l) # construct a new array

# END
