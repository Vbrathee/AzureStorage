pageextension 88013 vendLedgEntryExt extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here

    }


    actions
    {
        addlast(processing)
        {
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                    DocAttachMgmt: Codeunit "Document Attachment Mgmt";
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }

        }
    }
    trigger OnAfterGetCurrRecord()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        HasDocumentAttachment := false;
        CustLedgerEntry.Setrange("Transaction No.", Rec."Transaction No.");
        if CustLedgerEntry.findfirst then begin
            HasDocumentAttachment := CustLedgerEntry.HasPostedDocAttachment();
        end else begin
            VendLedgEntry.SetRange("Transaction No.", Rec."Transaction No.");
            if VendLedgEntry.FindFirst() then begin
                HasDocumentAttachment := VendLedgEntry.HasPostedDocAttachment();
            end;
        end;
    end;

    var
        HasDocumentAttachment: Boolean;
}