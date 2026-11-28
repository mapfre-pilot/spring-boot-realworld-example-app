a!localVariables(
  local!filas: append(ri!vivas, ri!historicas),
  local!claves: a!forEach(items: local!filas, expression: a!localVariables(
    local!fila: fv!item,
    a!toJson(a!map(celda: a!forEach(items: ri!agrupadores, expression: a!map(valor: index(local!fila, fv!item, null)))))
  )),
  local!unicas: union(touniformstring(local!claves), touniformstring(local!claves)),
  a!forEach(items: local!unicas, expression: a!localVariables(
    local!grupo: index(local!filas, wherecontains(fv!item, local!claves), {}),
    local!primera: index(local!grupo,1,a!map()),
    local!suma: sum(todecimal(index(local!grupo,"s",{}))),
    local!cantidad: sum(tointeger(index(local!grupo,"durCount",{}))),
    local!todosMax: index(local!grupo,"max",{}),
    local!maximos: index(local!todosMax,where(a!forEach(items:local!todosMax,expression:a!isNotNullOrEmpty(fv!item))),{}),
    a!map(
      g: index(local!primera,"g",null), m: index(local!primera,"m",null),
      d: index(local!primera,"d",null), c: index(local!primera,"c",null),
      t: index(local!primera,"t",null), e: index(local!primera,"e",null),
      p: index(local!primera,"p",null), q: index(local!primera,"q",null),
      n: sum(tointeger(index(local!grupo,"n",{}))),
      s: local!suma, durCount: local!cantidad,
      avg: if(local!cantidad>0, local!suma/local!cantidad, null),
      max: if(a!isNullOrEmpty(local!maximos),null,max(local!maximos))
    )
  ))
)