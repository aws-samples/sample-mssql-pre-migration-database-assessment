/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcelo Fernandes (marcesl) ; Marcos Freccia (mfreccia)
Date:           01/10/2021
Description:    Script to check if database is using CLR, will list all assemblies deployed at the database
Permission:     Requires membership in the public role.
*/

SELECT @@SERVERNAME AS SQLInstance,
		db_name() as DatabaseName,
        SCHEMA_NAME(O.schema_id) AS SchemaName,
		O.name as ObjectName,
        A.name AS AssemblyName,
		AM.assembly_class as AssemblyClass,
        AM.assembly_method as AssemblyMethod,
        A.permission_set_desc as PermissionSetDesc,
        O.[type_desc] as TypeDesc,
	getdate() as collect_date
FROM
        sys.assembly_modules (NOLOCK) AM
        INNER JOIN sys.assemblies (NOLOCK) A ON A.assembly_id = AM.assembly_id
        INNER JOIN sys.objects (NOLOCK) O ON O.object_id = AM.object_id
ORDER BY
        A.name, AM.assembly_class
