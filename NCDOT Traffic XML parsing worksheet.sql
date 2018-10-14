declare @x xml 
set @x='
<DataSet xmlns="http://www.w3.org/2001/XMLSchema">
   <xs:schema xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" id="NewDataSet">
   </xs:schema>
   <diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1">
     <NewDataSet xmlns="http://www.w3.org/2001/XMLSchema">
         <FolderData diffgr:id="FC337" msdata:rowOrder="336">
             <A>a1</A>
             <B>b1</B>
            <C>c1</C>
            <D>d1</D>         
 
        </FolderData>
     </NewDataSet>
 </diffgr:diffgram>
 </DataSet>'

;with xmlnamespaces('urn:schemas-microsoft-com:xml-msdata' as msdata,'urn:schemas-microsoft-com:xml-diffgram-v1' as diffgr,default 'http://www.w3.org/2001/XMLSchema' )
select x.i.value('./A[1]','varchar(MAX)'),
x.i.value('./B[1]','varchar(MAX)'),
x.i.value('./C[1]','varchar(MAX)'),
x.i.value('./D[1]','varchar(MAX)')
 from @x.nodes('/DataSet/diffgr:diffgram/NewDataSet/FolderData') as x(i)



DECLARE @XmlDocumentHandle int
DECLARE @XmlDocument XML, @ParseDate datetime2
	SET @ParseDate = SYSUTCDATETIME()
	SET @XmlDocument = (SELECT TOP 1 TrafficAccidents FROM [NC_Traffic_Accidents] ORDER BY CreatedDate DESC)

EXEC sp_xml_preparedocument @XmlDocumentHandle OUTPUT, @XmlDocument

;with xmlnamespaces('urn:schemas-microsoft-com:xml-msdata' as msdata,'urn:schemas-microsoft-com:xml-diffgram-v1' as diffgr,default 'http://www.w3.org/2001/XMLSchema' )
 SELECT [IncidentID]
	  , @ParseDate
FROM OPENXML (@XmlDocumentHandle, '/DataSet/diffgr:diffgram/NewDataSet/Table1',2)
WITH ([IncidentID] [int])
EXEC sp_xml_removedocument @XmlDocumentHandle;