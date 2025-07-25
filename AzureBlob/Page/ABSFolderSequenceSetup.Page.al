page 88004 "ABS Folder Sequence Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ABS Folder Sequence setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        InitEditable();

                    end;
                }

                field("Sequence Type"; Rec."Sequence Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        InitEditable();

                    end;
                }

                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                }

                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    Editable = FieldIDEditable;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }

                field("Folder Name"; Rec."Folder Name")
                {
                    ApplicationArea = All;
                    Editable = FolderNameEditable;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }
    var
        FolderNameEditable: Boolean;
        FieldIDEditable: Boolean;

    local procedure InitEditable()
    var
        myInt: Integer;
    begin
        if Rec."Sequence Type" = Enum::"ABS Sequence Type"::"Field Ref" then
            FieldIDEditable := true
        else
            FieldIDEditable := false;
        if Rec."Sequence Type" = Enum::"ABS Sequence Type"::Manual then
            FolderNameEditable := true
        else
            FolderNameEditable := false;
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        InitEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        myInt: Integer;
    begin
        Rec.SetUpNewLine();
    end;

}