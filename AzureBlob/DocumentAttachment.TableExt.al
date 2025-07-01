tableextension 88000 "Document Attachment" extends "Document Attachment"
{
    fields
    {
        field(88000; "Delete Azure BLOB"; Boolean)
        {
            Caption = 'Delete Azure BLOB';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    begin
        "Delete Azure BLOB" := true;
    end;
}
