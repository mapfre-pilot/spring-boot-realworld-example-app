if(a!isNullOrEmpty(ri!tipo),{},a!localVariables(
  local!pagina: 5000,
  if(a!isNullOrEmpty(ri!alias),
    a!queryRecordType(recordType:ri!tipo, fields:ri!campos,
      filters:ri!filtros, pagingInfo:a!pagingInfo(startIndex:1,batchSize:1)).data,
    a!localVariables(
      local!orden: a!forEach(items:ri!alias,expression:a!sortInfo(field:fv!item,ascending:true)),
      local!primera: a!queryRecordType(recordType:ri!tipo, fields:ri!campos,
        filters:ri!filtros, pagingInfo:a!pagingInfo(startIndex:1,batchSize:local!pagina,sort:local!orden)).data,
      if(length(local!primera) < local!pagina, local!primera,
        a!localVariables(
          local!conteo: a!queryRecordType(recordType:ri!tipo,
            fields:a!aggregationFields(measures:a!measure(function:"COUNT",field:ri!pk,alias:"filas")),
            filters:ri!filtros,pagingInfo:a!pagingInfo(startIndex:1,batchSize:1)).data,
          local!limite: tointeger(index(index(local!conteo,1,a!map()),"filas",0)),
          append(local!primera,a!flatten(a!forEach(
            items:enumerate(max(0,ceiling(local!limite/local!pagina)-1)),
            expression:a!queryRecordType(recordType:ri!tipo,
              fields:ri!campos,
              filters:ri!filtros,
              pagingInfo:a!pagingInfo(startIndex:1+(fv!item+1)*local!pagina,batchSize:local!pagina,sort:local!orden)).data
          )))
        )
      )
    )
  )
))