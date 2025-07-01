permissionset 88000 AzureStroage
{
    Assignable = true;
    Permissions = tabledata "ABS Container setup" = RIMD,
        table "ABS Container setup" = X,
        codeunit AttachedDocuments = X,
        page "ABS Container Content" = X,
        page "Azure Blob Storage" = X;
}