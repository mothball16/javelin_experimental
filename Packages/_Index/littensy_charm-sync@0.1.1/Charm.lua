local REQUIRED_MODULE = require(script.Parent.Parent["littensy_charm@0.8.1"]["charm"])
export type Atom<State> = REQUIRED_MODULE.Atom<State>
export type Selector<State> = REQUIRED_MODULE.Selector<State>
export type Molecule<State> = REQUIRED_MODULE.Molecule<State>
export type SyncPayload = REQUIRED_MODULE.SyncPayload 
return REQUIRED_MODULE
