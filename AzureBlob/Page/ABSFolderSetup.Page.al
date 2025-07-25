page 88005 "ABS Folder Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ABS Folder setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Enable Folder Sequence"; Rec."Enable Folder Sequence")
                {
                    ApplicationArea = All;
                }
                field("Folder Name"; Rec."Folder Name")
                {
                    ApplicationArea = All;
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
            action(FolderSequenceSetup)
            {
                Caption = 'Folder Sequence Setup';
                ApplicationArea = All;

                // Promoted = true;
                // PromotedIsBig = true;
                RunObject = Page "ABS Folder Sequence Setup";
                RunPageLink = "Table ID" = field("Table ID"), "Document Type" = field("Document Type");
                trigger OnAction()
                begin

                end;
            }
        }
    }

}