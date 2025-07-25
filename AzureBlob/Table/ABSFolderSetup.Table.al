table 88001 "ABS Folder setup"
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

        field(3; "Folder Name"; Text[250])
        {
            Caption = 'Folder Name';
            DataClassification = CustomerContent;
        }
        field(6; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            Editable = False;
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object ID" = Field("Table ID")));
            // DataClassification = CustomerContent;
        }

        field(7; "Enable Folder Sequence"; Boolean)
        {
            Caption = 'Enable Folder Sequence';
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document Type")
        {
            Clustered = true;
        }
    }

}