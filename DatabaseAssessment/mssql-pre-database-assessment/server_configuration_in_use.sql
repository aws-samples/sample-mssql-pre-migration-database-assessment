/*
#
# // Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# // SPDX-License-Identifier: MIT-0

*/

/*
Author:         Marcos Freccia (mfreccia)
Date:           25/11/2022
Description:    Script to retrieve configuration (sp_configure) from the instance.
Permission:     Requires membership in the public role.
*/


SELECT @@SERVERNAME AS SQLInstance,
    name as ConfigurationName, value_in_use as 'State', GETDATE() as collect_date
FROM sys.configurations (NOLOCK)
