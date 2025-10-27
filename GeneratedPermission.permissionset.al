namespace generatepermission;

permissionset 88001 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "ABS Container Acc setup"=RIMD,
        tabledata "ABS Folder Sequence setup"=RIMD,
        tabledata "ABS Folder setup"=RIMD,
        table "ABS Container Acc setup"=X,
        table "ABS Folder Sequence setup"=X,
        table "ABS Folder setup"=X,
        codeunit AttachedDocuments=X,
        codeunit AzureContainermgmt=X,
        codeunit "Copy Inv Attch To Order"=X,
        codeunit "Copy Purch Inv Attch To Order"=X,
        codeunit CopyToPostedDoc=X,
        codeunit "Doc Attach To BlobStorage"=X,
        codeunit "Incoming Doc To DocAttach"=X,
        page "ABS Container Content"=X,
        page "ABS Folder Sequence Setup"=X,
        page "ABS Folder Setup"=X,
        page "Azure Blob Storage"=X,
        page "Container Management Test"=X;
}