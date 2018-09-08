pragma solidity 0.4.24;

library ResourcesLibrary {
    
    struct Resources {
        uint72 level;
        uint24 density;
        uint24 eStock;
        uint24 gStock;
        uint24 mStock;
        uint32 endUpgrade;
        uint32 lastHarvest;
    }
    
    function getLevel(Resources self)
        internal
        pure
        returns(uint[9] memory l )
    {
        bytes9 b = bytes9(self.level);
        l[0] = uint(b[8]);
        l[1] = uint(b[7]);
        l[2] = uint(b[6]);
        l[3] = uint(b[5]);
        l[4] = uint(b[4]);
        l[5] = uint(b[3]);
        l[6] = uint(b[2]);
        l[7] = uint(b[1]);
        l[8] = uint(b[0]);
    }
    
    function toUint24(uint[3] a)
        external
        pure
        returns(uint24 r)
    {
        r = uint24(set8(r,0,a[0]));
        r = uint24(set8(r,8,a[1]));
        r = uint24(set8(r,16,a[2]));
    }
    
    function toUint72(uint[9] a)
        external
        pure
        returns(uint72 r)
    {
        r = uint24(set8(r,0,a[0]));
        r = uint24(set8(r,8,a[1]));
        r = uint24(set8(r,16,a[2]));
        r = uint24(set8(r,24,a[3]));
        r = uint24(set8(r,32,a[4]));
        r = uint24(set8(r,40,a[5]));
        r = uint24(set8(r,48,a[6]));
        r = uint24(set8(r,56,a[7]));
        r = uint24(set8(r,64,a[8]));
    }
    
    function set8(uint store, uint bitfrom, uint value)
        internal
        pure
        returns(uint ret)
    {
        uint shift = 2 ** bitfrom;
        uint mask = ~(0xff * shift);
        ret = store & mask | (value * shift);
    }
    
    function getDensity(Resources self)
        internal
        pure
        returns(uint[3] memory l )
    {
        bytes3 b = bytes3(self.density);
        l[0] = uint(b[2]);
        l[1] = uint(b[1]);
        l[2] = uint(b[0]);
    }
    
    function commit(Resources storage self, Resources memory r)
        internal
    {
        self.level = r.level;
        self.density = r.density;
        self.eStock = r.eStock;
        self.gStock = r.gStock;
        self.mStock = r.mStock;
        self.endUpgrade = r.endUpgrade;
        self.lastHarvest = r.lastHarvest; 
    }
}
