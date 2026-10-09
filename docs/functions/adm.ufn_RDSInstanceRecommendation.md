# dbo.ufn_RDSInstanceRecommendation

## Description

This function makes a calculation of the CPU utilization of the databases passed as a parameter and provides a recommendation for the instance size. This script relies on the following objects.

- Tables
  - dbo.rds_instance_sizes
- Views
  - dbo.vw_database_general_information

The results are an estimative to help consultants on providing estimations for RDS Instance sizes.

## How to use

To successfully use this function, you can invoke in the following way.

```SQL

use AwsDatabaseAssessment
GO
select [dbo].[ufn_RDSInstanceRecommendation]('Database1,Database2','SQLInstance')
```

## Sample Results

| Results |
|---------|
|`[{"instance_type":"db.r6i.large","vcpu":2,"memory":16}]`|
