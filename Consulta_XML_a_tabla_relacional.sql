/*1 - Consultar todos los registros cargados en la tabla con el código de Python*/
	SELECT [id]
	      ,[XmlCol]
	      ,[local_path]
	      ,[container_folder_name]
	      ,[name_file]
	  FROM [test_xml_python].[dbo].[data_xml]

/*2 - Con la siguiente consulta se pueden comenzar a independizar en columnas los diferentes atributos de los XML*/

	SELECT 
		'PostCode'				=	XmlCol.value('(Data/PostCode)[1]','VARCHAR(200)')
	,	'Country'				=	XmlCol.value('(Data/Country)[1]','VARCHAR(200)')
	,	'CountryAbbreviation'	=	XmlCol.value('(Data/CountryAbbreviation)[1]','VARCHAR(200)')
	,	'DataCreationDate'		=	XmlCol.value('(Data/DataCreationDate)[1]','VARCHAR(200)')
	,	'DataCreationTime'		=	XmlCol.value('(Data/DataCreationTime)[1]','VARCHAR(200)')
	,	'User'					=	XmlCol.value('(Data/User)[1]','VARCHAR(200)')
		/*Si un atributo internamente tiene otros atributos, la información de los subatributos se visualizará unida ya que no se está especificando al detalle el atributo*/
	,	'Statistics'			=	XmlCol.value('(Data/Statistics)[1]','VARCHAR(200)')
	,	'PlaceCount'			=	XmlCol.value('(Data/Statistics/PlaceCount)[1]','VARCHAR(200)')
	,	'StateCount'			=	XmlCol.value('(Data/Statistics/StateCount)[1]','VARCHAR(200)')
	
		/*Si un atributo internamente tiene una LISTA de otros atributos, la información de los subatributos de la LISTA se visualizará unida ya que no se está especificando el elemento ni el detalle el atributo de la lista*/
	,	'Places'	=	XmlCol.value('(Data/Places)[1]','VARCHAR(200)')	
	
		/*Cuando se tiene una lista de elementos con sus respectivos atributos
			se utiliza el número dentro de los corchetes para acceder al elemento según la posición donde está ubicado
			SI dicha posición no existe SQL mostrará la información como NULL.
		*/
	,	'Place'	=	XmlCol.value('(Data/Places/Place)[2]','VARCHAR(200)')
		/*En caso de obtener el atributo de un elemento de la lista, se necesario especificar la posición (indice) y la ruta completa del atributo*/
	,	'Place_Index_2_PlaceName'	=	XmlCol.value('(Data/Places/Place/Values/PlaceName)[2]','VARCHAR(200)')
	--,	''	=	XmlCol.value('()[1]','VARCHAR(200)')
	,	[id]
	,	[XmlCol]
	,	[local_path]
	,	[container_folder_name]
	,	[name_file]	
	FROM
		[test_xml_python].[dbo].[data_xml]
	WHERE 1=1
		AND name_file <> 'Plantilla.xml'
		--AND XmlCol.value('(Data/PostCode)[1]','VARCHAR(200)') = '1602'

/*3 - USO del CROSS APPLY en SQL Server: la función de CROSS APPLY permite devolver en multiples fila o registros, cuando un atributo del XML
		contiene una lista de elementos y se requieren visualizar como datos independientes.
		Para este ejemplo ya puedo acceder al atributo "Values/PlaceName" de cada elemento que se encuentra en la lista de elementos de la ruta "Data/Places/Place".
		Es una forma de volver recursiva la información de una columna.
		*/
	SELECT
		'PostCode'				=	XmlCol.value('(Data/PostCode)[1]','VARCHAR(200)')
	,	'PlaceName'				=	value_attribute.value('(PlaceName)[1]','VARCHAR(200)')
	,	'Longitude'				=	value_attribute.value('(Longitude)[1]','VARCHAR(200)')
	,	'State'					=	value_attribute.value('(State)[1]','VARCHAR(200)')
	,	'StateAbbreviation'		=	value_attribute.value('(StateAbbreviation)[1]','VARCHAR(200)')
	,	'Latitude'				=	value_attribute.value('(Latitude)[1]','VARCHAR(200)')

	FROM
		[test_xml_python].[dbo].[data_xml] AS dx
		CROSS APPLY XmlCol.nodes('//Places/Place/Values') AS place_values(value_attribute)
	WHERE 1=1
		AND dx.name_file <> 'Plantilla.xml'
		--AND XmlCol.value('(Data/PostCode)[1]','VARCHAR(200)') = '1602'