permissionset 88000 AzureStroage
{
    Assignable = true;
    Permissions = tabledata "ABS Container setup"=RIMD,
        tabledata "PDFV2 PDF Storage"=RIMD,
        table "ABS Container setup"=X,
        table "PDFV2 PDF Storage"=X,
        codeunit AttachedDocuments=X,
        page "ABS Container Content"=X,
        page "Azure Blob Storage"=X,
        page "PDFV2 PDF Storage"=X,
        page "PDFV2 PDF Viewer"=X;
}