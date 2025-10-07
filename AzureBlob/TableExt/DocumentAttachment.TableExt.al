tableextension 88000 "Document Attachment" extends "Document Attachment"
{
    fields
    {
        field(88000; "Delete Azure BLOB"; Boolean)
        {
            Caption = 'Delete Azure BLOB';
            DataClassification = ToBeClassified;
        }
        field(88001; "Folder Name"; Text[1024])
        {
            Caption = 'Folder Name';
            DataClassification = ToBeClassified;
        }
        field(88002; "Moved Attachment"; Boolean)
        {
            Caption = 'Moved Attachment';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    begin
        "Delete Azure BLOB" := true;
    end;
}
