#!/usr/local/bin/lua
--[[
    Author          :   Kyle Falconer
    Assignment      :   Project 2 – Lua
    Class           :   CSC 333, Fall 2012
    Last Modified   :   Dec 5 2012
    Lua version     :   5.2.1


    Solution to "Go Go Gorelians" [moderate/hard]
    http://mcpc.cigas.net/archives/2006/mcpc2006/gorelian/gorelian.html
    2006 ACM Mid-Central USA Regional Programming Contest
    Adapted from the Java solution given by Ron Pacheco
    
    ==============================
    
    Copyright 2012 Kyle Falconer

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    
]]--


function main()

    local filename = "gorelian.in"
    local f = assert(io.open(filename, "r"))
    local N = f:read("*n")
    while N > 0 do
        g = Gorelian:new(f,N)
        g:solve()
        N = f:read("*n")
        if N > 0 then io.write("\n") end
    end

end


Gorelian =  {
    _n      =   0,  -- int
    _adj    =   {}, -- boolean[][]
    _deg    =   {}, -- int[]
    _x      =   {}, -- int[]
    _y      =   {}, -- int[]
    _z      =   {}  -- int[]
}

function Gorelian:new (f, N)

    -- print("\n\nN : "..N)

    self._n = 0

    self._adj = {}
    for i = 0, 1001 do
        self._adj[i] = {}
        for j = 0, 1001 do
            self._adj[i][j] = false
        end
    end

    self._x = {}
    for i = 0, 1001 do
        self._x[i] = 0
    end

    self._y = {}
    for i = 0, 1001 do
        self._y[i] = 0
    end

    self._z = {}
    for i = 0, 1001 do
        self._z[i] = 0
    end

    self._deg = {}
    for i = 0, 1001 do
        self._deg[i] = 0
    end
    
    local id1 = f:read("*n")
    -- print("id1 : "..id1)
    self:addNode( id1, f:read("*n"), f:read("*n"), f:read("*n") )
    local id2 = f:read("*n")
    -- print("id2 : "..id2)
    self:addNode( id2, f:read("*n"), f:read("*n"), f:read("*n") )
    self:link( id1, id2 )
    N = N - 2
    while N > 0 do
        id1 = f:read("*n")
        -- print("id1 : "..id1)
        self:addNode( id1, f:read("*n"), f:read("*n"), f:read("*n") )
        id2 = self:nearestNeighbor(id1)
        -- print("nearestNeighbor : "..id2)
        self:link( id1, id2 )

        N = N - 1
    end

    --[[
    print("\n<GRAPH_DUMP>")
    self:dumpGraph()
    print("</GRAPH_DUMP>\n")
    ]]--
    return self
end

function Gorelian:addNode(id, x, y, z)
    --[[ print("addNode( "..id..", "..x..", "..y..", "..z.." )") ]]--
    self._adj[id][id] = true
    self._x[id] = x
    self._y[id] = y
    self._z[id] = z
    self._n = self._n + 1
end

function Gorelian:link(id1, id2)
    -- print("link( "..id1..", "..id2.." )")
    self._adj[id1][id2] = true
    self._adj[id2][id1] = true
    self._deg[id1] = self._deg[id1] +1
    self._deg[id2] = self._deg[id2] +1
end

function Gorelian:removeNode(id)
    --[[ print("removeNode( "..id.." )") ]]--
    for i = 1, 1000 do
        if self._adj[id][i] then
            self._adj[id][i] = false;
            self._adj[i][id] = false;
            self._deg[i] = self._deg[i] - 1
        end
    end
    self._deg[id] = 0
    self._n = self._n - 1
end

function Gorelian:nearestNeighbor(id)
    local nearestId = 0
    local nearestDist = 999999999
    for i = 1, 1000 do
        if i ~= id and self._deg[i] > 0 and self:dist( i, id ) < nearestDist then
            nearestId = i
            nearestDist = self:dist( i, id )
            -- print("dist( "..i..", "..id.." ) : "..nearestDist)
        end
    end
    --[[ print("nearestNeighbor( "..id.." ) : "..nearestId) ]]--
    return nearestId
end

function Gorelian:dist(id1, id2)
    local dx = self._x[id1] - self._x[id2]
    local dy = self._y[id1] - self._y[id2]
    local dz = self._z[id1] - self._z[id2]
    local _dist = dx * dx + dy * dy + dz * dz
    --[[ print("dist( "..id1..", "..id2.." ) : "..dx..", "..dy..", "..dz.." -> ".._dist) ]]--
    return _dist
end

function Gorelian:dumpGraph()
    for i = 1, 1000 do
        if self._deg[i] > 0 then
            io.write(i.."("..self._deg[i].."):")
            for j = i+1, 1000 do
                if self._adj[i][j] then
                    io.write(" "..j)
                end
            end
            print("")
        end
    end
end

function Gorelian:solve()

    local leaf = {}
    for i = 0, 1001 do
        leaf[i] = false
    end

    while self._n > 2 do
        -- print("self._n > 2;\tn = "..self._n)
        for i = 1, 1000 do
            if self._deg[i] == 1 then
                leaf[i] = true
            else
                leaf[i] = false
            end
        end
        for i = 1, 1000 do
            if leaf[i] then
                self:removeNode(i)
            end
        end
    end

    if self._n == 1 then
        -- print("self._n == 1")
        for i = 1, 1000 do
            if self._adj[i][i] then
                io.write(i)
            end
        end
    else
        -- print("self._n ~= 1;\t_n = "..self._n)
        local n = 0
        for i = 1, 1000 do
            --[[ io.write("self._adj[i][i] = "..tostring(self._adj[i][i])) ]]--
            if self._adj[i][i] then
                io.write(i)
                if n == 0 then
                    io.write(" ")
                end
                n = n + 1
            end
        end    
    end
    --[[
    -- I moved this line to main() to fix the \n before the <EOF>
    io.write("\n")
    ]]--
end


main()