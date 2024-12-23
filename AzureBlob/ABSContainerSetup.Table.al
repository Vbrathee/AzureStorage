table 88000 "ABS Container setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Account Name"; Text[250])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
        }
        field(3; "Container Name"; Text[250])
        {
            Caption = 'Container Name';
            DataClassification = CustomerContent;
        }
        field(4; "Shared Access Key"; Text[250])
        {
            Caption = 'Shared Access Key';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}