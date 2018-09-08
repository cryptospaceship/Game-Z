pragma solidity 0.4.24;

contract Contract {
    
    using ResourcesLibrary for ResourcesLibrary.Resources;
    
    mapping (uint => ResourcesLibrary.Resources) resources;
    
    constructor() public {
        resources[0].eStock = 10000;
        resources[0].gStock = 10000;
        resources[0].mStock = 10000;
    }
    
    function upgradeResourceInternal(uint _id, uint _type, uint _index)
        external
    {
        ResourcesLibrary.Resources memory r = resources[_id];
        uint energy;
        uint graphene;
        uint metal;
        uint end;
        uint level = getResourceLevelByType(r, _type, _index) + 1;
        
        require(level <= 10);
        (energy,graphene,metal,end) = GameLib.getUpgradeResourceCost(_type,level,0);

        (energy,graphene,metal) = collectResourcesAndSub(_id,energy,graphene,metal);
        
        r.endUpgrade = uint32(end);
        r.lastHarvest = uint32(block.number);
        r.eStock = uint24(energy);
        r.gStock = uint24(graphene);
        r.mStock = uint24(metal);
        r.level = addResourceLevel(r, _type,_index);
        resources[_id].commit(r);
    }
    
    function addResourceLevel (ResourcesLibrary.Resources memory r, uint _type, uint _index) 
        internal
        pure
        returns(uint72)
    {
        uint[9] memory level = r.getLevel();
        if (_type == 0) {
            level[_index+1]++;
            level[uint(GameLib.ResourceIndex.INDEX_UPGRADING)] = _index+1;
            return ResourcesLibrary.toUint72(level);
        }
        if (_type == 1) {
            level[uint(GameLib.ResourceIndex.GRAPHENE)]++; 
            level[uint(GameLib.ResourceIndex.INDEX_UPGRADING)] = uint(GameLib.ResourceIndex.GRAPHENE);
            return ResourcesLibrary.toUint72(level);
        }
        if (_type == 2) { 
            level[uint(GameLib.ResourceIndex.METAL)]++; 
            level[uint(GameLib.ResourceIndex.INDEX_UPGRADING)] = uint(GameLib.ResourceIndex.METAL);
            return ResourcesLibrary.toUint72(level);
        }
    }
    
    function getResourceLevelByType( ResourcesLibrary.Resources memory r, uint _type, uint _index)
        internal
        view
        returns(uint)
    {
        uint[6] memory e;
        uint g;
        uint m;

        (e,g,m) = getResourceLevel(r.getLevel(),r.endUpgrade);

        if (_type == 0) 
            return e[_index];
        if (_type == 1) 
            return g;
        if (_type == 2) 
            return m;
    }

    
    function getResourceLevel (uint[9] memory level, uint endUpgrade) 
        internal 
        view 
        returns(uint[6] e, uint g, uint m) 
    {
        uint i;
        for ( i = 0; i < 6; i++ ) 
            e[i] = level[i+1];
            
        g = level[uint(GameLib.ResourceIndex.GRAPHENE)];
        m = level[uint(GameLib.ResourceIndex.METAL)];

        if (block.number < endUpgrade) {
            i = level[uint(GameLib.ResourceIndex.INDEX_UPGRADING)];
            if ( i == uint(GameLib.ResourceIndex.GRAPHENE) ) {
                g--;
                return;
            }
            if ( i == uint(GameLib.ResourceIndex.METAL) ) {
                m--;
                return;
            }
            e[i-1]--;
        }
    }
    
    function collectResourcesAndSub(uint _id, uint e, uint g, uint m)
        internal
        view
        returns(uint, uint, uint)
    {
        ResourcesLibrary.Resources memory r = resources[_id];
        uint energy;
        uint graphene;
        uint metal;
        
        (energy, graphene, metal) = getResources(_id);
        require(
            r.lastHarvest <= block.number && 
            energy >= e && graphene >= g && metal >= m    
        );
        
        return (energy-e, graphene-g, metal-m);
    }

    
    
    function getResources(uint _id)
        internal
        view
        returns(uint energy, uint graphene, uint metal)    
    {
        ResourcesLibrary.Resources memory r = resources[_id];
        (energy,graphene,metal) = getUnharvestResources(_id);
        uint maxLoad = 10000;
        
        energy = energy + r.eStock;
        if (energy > maxLoad) 
            energy = maxLoad;

        graphene = graphene + r.gStock;
        if (graphene > maxLoad)
            graphene = maxLoad;
        
        metal = metal + r.mStock;
        if (metal > maxLoad)
            metal = maxLoad;
    }
    
    function getUnharvestResources(uint _id)
        internal
        view
        returns(uint energy, uint graphene, uint metal)
    {
        ResourcesLibrary.Resources memory r = resources[_id];
        (energy,graphene,metal) = GameLib.getUnharvestResources(
            r.getLevel(), 
            uint(r.endUpgrade), 
            r.getDensity(), 
            0,
            0, 
            uint(r.lastHarvest)
        );
    }
    
}