permissionset 88000 AzureStroage
{
    Assignable = true;
    Permissions = tabledata "ABS Container Acc setup" = RIMD,
        table "ABS Container Acc setup" = X,
        codeunit AttachedDocuments = X,
        page "ABS Container Content" = X,
        page "Azure Blob Storage" = X,
        tabledata "ABS Folder setup" = RIMD,
        table "ABS Folder setup" = X,
        Codeunit "ABS Container Client" = X,
        Codeunit "ABS Operation Response" = X,
        Codeunit "Storage Service Authorization" = X,
        tabledata "ABS Container" = RIMD,
        table "ABS Container" = X;

}