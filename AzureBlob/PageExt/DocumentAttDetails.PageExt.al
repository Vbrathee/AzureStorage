pageextension 88000 DocumentAttDetailsExt extends "Document Attachment Details"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            action(DownloadBlob)
            {
                ApplicationArea = All;
                Caption = 'Download Blob';
                Image = Download;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Download the file to your device. Depending on the file, you will need an app to view or edit the file.';

                trigger OnAction()
                var
                    ABSBlobClient: codeunit "ABS Blob Client";
                    Authorization: Interface "Storage Service Authorization";
                    ABSContainersetup: Record "ABS Container Acc setup";
                    StorageServiceAuthorization: Codeunit "Storage Service Authorization";
                    Instream: InStream;
                    Filename: Text;
                begin
                    if Rec."File Name" <> '' then begin
                        ABSContainersetup.Get;
                        Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
                        ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
                        if Strpos(Rec."Folder Name", '.' + Rec."File Extension") <> 0 then
                            Filename := Rec."Folder Name"
                        else if Rec."Folder Name" <> '' then
                            Filename := Rec."Folder Name" + '/' + Rec."File Name" + '.' + Rec."File Extension"
                        else
                            Filename := Rec."File Name" + '.' + Rec."File Extension";
                        ABSBlobClient.GetBlobAsFile(Filename);
                    End;
                end;
            }
            action(MoveBlob)
            {
                ApplicationArea = All;
                Caption = 'Move Attachment to Blob Storage';
                Image = Download;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Move Attachment to Blob Storage';

                trigger OnAction()
                var
                    DocAttachmentMover: Codeunit "Doc Attach To BlobStorage";
                    DocumentAttachment: Record "Document Attachment";
                begin
                    DocumentAttachment.SetRange(ID, Rec.ID);
                    DocumentAttachment.Setrange("Table ID", rec."Table ID");
                    DocumentAttachment.SetRange("No.", Rec."No.");
                    DocumentAttachment.SetRange("Document Type", Rec."Document Type");
                    DocumentAttachment.SetRange("Line No.", Rec."Line No.");
                    if DocumentAttachment.FindFirst() then
                        DocAttachmentMover.MoveSingleDocAttchmentToBlobStorage(DocumentAttachment, true);
                    CurrPage.Update(false);
                end;
            }
            action(MoveAllBlob)
            {
                ApplicationArea = All;
                Caption = 'Move All Attachment to Blob Storage';
                Image = Download;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Move All Attachment to Blob Storage';

                trigger OnAction()
                var
                    DocAttachmentMover: Codeunit "Doc Attach To BlobStorage";
                    DocumentAttachment: Record "Document Attachment";
                begin
                    DocAttachmentMover.MoveAllIncomingDocAttachtoBlobStorage(true);
                    CurrPage.Update(false);
                end;
            }


        }
    }

    var
        myInt: Integer;
}