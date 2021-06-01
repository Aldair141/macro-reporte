DECLARE @cols AS NVARCHAR(MAX),
@query AS NVARCHAR(MAX);

select @cols = STUFF(( SELECT ',[', au.descripcion, ']'
	FROM FILASUR.atributo_registro ar 
	INNER JOIN FILASUR.atributo_ubicacion au 
	ON ar.tipo_producto = au.tipo_producto AND ar.codigo = au.codigo
	INNER JOIN FILASUR.ARTICULO ART ON AR.rowpointer=ART.RowPointer 
	INNER JOIN FILASUR.ARTICULO_ABREVIADO ARTA ON AR.rowpointer=ARTA.ROWPOINTER
	INNER JOIN FILASUR.ATRIBUTO_UBICACION AU2 ON AR.codigo=AU2.CODIGO AND AU2.DETALLE LIKE '%' + ar.valor_texto + '%'
	AND AU2.TIPO_PRODUCTO=AR.tipo_producto
	WHERE ar.rowpointer = 'D355952A-FEA6-4B77-9CC6-EE2006412F38' AND 
	AU.ubicacion IN ('C') AND au.TIPO NOT IN ('V','C') AND ar.tipo_producto =  'HILO' FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,2,'[');

set @query =  'select * from (SELECT ar.tipo_producto,ART.ARTICULO,ARTA.descripcion  AS DESC_ART,au.descripcion,
	Substring (AU.DETALLE, Charindex( ar.valor_texto + ''='', AU.DETALLE ) 
	+ Len(ar.valor_texto) + 1,
	Charindex( ''|'', Substring (AU.DETALLE, Charindex( ar.valor_texto + ''='', AU.DETALLE ) 
	+ Len(ar.valor_texto) + 1,Charindex( ''|'', AU.DETALLE )) ))   
	AS DETALLE_ART
	FROM FILASUR.atributo_registro ar 
	INNER JOIN FILASUR.atributo_ubicacion au 
	ON ar.tipo_producto = au.tipo_producto AND ar.codigo = au.codigo
	INNER JOIN FILASUR.ARTICULO ART ON AR.rowpointer=ART.RowPointer 
	INNER JOIN FILASUR.ARTICULO_ABREVIADO ARTA ON AR.rowpointer=ARTA.ROWPOINTER
	INNER JOIN FILASUR.ATRIBUTO_UBICACION AU2 ON AR.codigo=AU2.CODIGO AND AU2.DETALLE LIKE ''%'' + ar.valor_texto + ''%''
	AND AU2.TIPO_PRODUCTO=AR.tipo_producto
	WHERE ar.rowpointer = ''D355952A-FEA6-4B77-9CC6-EE2006412F38'' AND 
	AU.ubicacion IN (''C'') AND au.TIPO NOT IN (''V'',''C'') AND ar.tipo_producto =  ''HILO''
) s
pivot (
	MAX(DETALLE_ART)
	FOR [descripcion] in (' + @cols + ')
) P';

exec(@query);