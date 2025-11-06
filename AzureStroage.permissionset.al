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
        table "ABS Container" = X,
        tabledata "ABS Folder Sequence setup" = RIMD,
        table "ABS Folder Sequence setup" = X,
        codeunit AzureContainermgmt = X,
        codeunit "Copy Inv Attch To Order" = X,
        codeunit "Copy Purch Inv Attch To Order" = X,
        codeunit CopyToPostedDoc = X,
        codeunit "Doc Attach To BlobStorage" = X,
        codeunit "Incoming Doc To DocAttach" = X,
        page "ABS Folder Sequence Setup" = X,
        page "ABS Folder Setup" = X,
        page "Container Management Test" = X;
}