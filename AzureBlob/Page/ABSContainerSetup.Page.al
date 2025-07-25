page 88000 "Azure Blob Storage"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'ABS Container Setup';
    UsageCategory = Administration;
    SourceTable = "ABS Container Acc setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Enable Container Setup"; Rec."Enable Container Setup")
                {
                    ApplicationArea = all;
                    //ExtendedDatatype = Masked;
                }

                field("Enable Folder Setup"; Rec."Enable Folder Setup")
                {
                    ApplicationArea = all;
                    //ExtendedDatatype = Masked;
                }

                field(AccountName; rec."Account Name")
                {
                    ApplicationArea = all;
                }
                field(ContainerName; rec."Container Name")
                {
                    ApplicationArea = all;
                }
                field(SharedAccessKey; rec."Shared Access Key")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FolderSetup)
            {
                ApplicationArea = All;

                //Promoted = true;
                //PromotedIsBig = true;
                RunObject = Page "ABS Folder Setup";
                trigger OnAction()
                begin

                end;
            }
        }
    }
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSBlobClient: codeunit "ABS Blob Client";
        ABSContainerClient: Codeunit "ABS Container Client";
        Authorization: Interface "Storage Service Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerContent: Record "ABS Container Content";
}