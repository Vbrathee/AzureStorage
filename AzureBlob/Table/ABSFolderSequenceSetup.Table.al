table 88002 "ABS Folder Sequence setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(2; "Document Type"; Enum "Attachment Document Type")
        {
            Caption = 'Document Type';
        }


        field(4; "Sequence Type"; Enum "ABS Sequence Type")
        {
            Caption = 'Sequence Type';
            DataClassification = CustomerContent;
        }
        field(5; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
        field(6; "Folder Name"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Field ID"; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(8; "Field Name"; Text[250])
        {
            //DataClassification = CustomerContent;
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field.FieldName where(TableNo = Field("Table ID"), "No." = field("Field ID")));
        }
        field(9; "Type"; Enum "ABS Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document Type", "Sequence No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        //    if "Sequence No."= 0 then begin

        //  end;
    end;

    procedure SetUpNewLine()
    var
        ABSFolderSequenceSetup: Record "ABS Folder Sequence setup";
    begin
        ABSFolderSequenceSetup.SetRange("Table ID", "Table ID");
        ABSFolderSequenceSetup.SetRange("Document Type", "Document Type");
        //CommentLine.SetRange(Date, WorkDate());
        if ABSFolderSequenceSetup.FindLast() then
            ABSFolderSequenceSetup."Sequence No." := "Sequence No." + 1;


    end;

    var
        SalesCommentLine: record "Sales Comment Line";
        pgSalesCommentLine: Page "Comment Sheet";


}